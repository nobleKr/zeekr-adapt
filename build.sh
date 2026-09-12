#!/usr/bin/env bash
#
# build.sh — Compile DHU Adapter Java sources into dex + smali for injection
#
# Prerequisites:
#   - Java 21 (javac)
#   - Android SDK build-tools 36.1.0 (d8)
#   - baksmali
#   - libs/pine.jar (see README)
#
set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { printf "${CYAN}[INFO]${NC}  %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
die()   { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }

# ── Paths ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [[ -z "$ANDROID_HOME" ]]; then
    for cand in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "$HOME/android-sdk" "/usr/lib/android-sdk"; do
        [[ -d "$cand" ]] && { ANDROID_HOME="$cand"; break; }
    done
    ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
fi
BUILD_TOOLS="$ANDROID_HOME/build-tools/36.1.0"
PLATFORM="$ANDROID_HOME/platforms/android-34/android.jar"

# ── Prerequisite checks ────────────────────────────────────────────────────
check_tool() {
    command -v "$1" &>/dev/null || die "'$1' not found in PATH. Please install it first."
}

check_tool javac
[[ -x "$BUILD_TOOLS/d8" ]] || die "Android SDK build-tools 36.1.0 not found (looked in: $BUILD_TOOLS).
  Install the Android SDK and set ANDROID_HOME, then:
    sdkmanager \"build-tools;36.1.0\" \"platforms;android-34\"
  (searched ANDROID_HOME/ANDROID_SDK_ROOT and common locations — see README)."
[[ -f "$PLATFORM" ]]       || die "Android platform android-34 not found (looked in: $PLATFORM).
  Install it: sdkmanager \"platforms;android-34\"  (set ANDROID_HOME first)."

# d8 crashes on IBM Semeru / Eclipse OpenJ9 (ScavengerRootScanner assertion,
# "Misaligned object" core dump). Require a HotSpot JVM (Temurin/Oracle/Zulu).
JVM_NAME="$(java -version 2>&1)"
if printf '%s' "$JVM_NAME" | grep -qiE 'openj9|semeru'; then
    die "Your 'java' is IBM Semeru / OpenJ9 — d8 crashes on it (Misaligned object /
  ScavengerRootScanner assertion). Use a HotSpot JVM (Temurin 21):

    export JAVA_HOME=/path/to/temurin-21
    export PATH=\"\$JAVA_HOME/bin:\$PATH\"
    java -version    # must NOT say OpenJ9/Semeru

  Then re-run ./build.sh"
fi

# ── Resolve baksmali / smali ────────────────────────────────────────────────
# Prefer a `baksmali`/`smali` already on PATH; otherwise auto-download the
# standalone fat-release jars from github.com/baksmali/smali into libs/ (once)
# and invoke them via `java -jar`. Sets $BAKSMALI and $SMALI to a runnable command.
SMALI_VERSION="3.0.10"
SMALI_BASE="https://github.com/baksmali/smali/releases/download/${SMALI_VERSION}"
resolve_smali_tool() {   # $1 = baksmali|smali  → echoes a runnable command
    local name="$1"
    if command -v "$name" &>/dev/null; then
        echo "$name"; return 0
    fi
    local jar="$SCRIPT_DIR/libs/${name}.jar"
    if [[ ! -f "$jar" ]]; then
        info "'$name' not on PATH — downloading ${name} ${SMALI_VERSION} fat jar..." >&2
        mkdir -p "$SCRIPT_DIR/libs"
        curl -fsSL -o "$jar" "${SMALI_BASE}/${name}-${SMALI_VERSION}-fat-release.jar" >&2 \
            || die "Failed to download $name from $SMALI_BASE (check network); or install $name on PATH — see README."
    fi
    echo "java -jar $jar"
}
BAKSMALI="$(resolve_smali_tool baksmali)"
SMALI="$(resolve_smali_tool smali)"

# ── Check dependencies ─────────────────────────────────────────────────────
LIBS_DIR="$SCRIPT_DIR/libs"
PINE_JAR="$LIBS_DIR/pine.jar"

if [[ ! -f "$PINE_JAR" ]]; then
    PINE_B64="$SCRIPT_DIR/vendor/pine.jar.base64"
    if [[ -f "$PINE_B64" ]]; then
        info "pine.jar not found — decoding vendored Pine (vendor/pine.jar.base64)..."
        mkdir -p "$LIBS_DIR"
        # portable: GNU base64 -d and BSD/macOS base64 -d both accept stdin
        base64 -d < "$PINE_B64" > "$PINE_JAR" 2>/dev/null \
            || base64 -D < "$PINE_B64" > "$PINE_JAR" 2>/dev/null \
            || die "Failed to decode $PINE_B64"
        ok "Pine restored to $PINE_JAR"
    else
        die "Pine library not found at $PINE_JAR (and vendor/pine.jar.base64 missing)

  Build it from source and place it at: $PINE_JAR
    git clone https://github.com/canyie/pine
    cd pine && ./gradlew :core:assembleRelease
    cp core/build/outputs/aar/core-release.aar $LIBS_DIR/pine.jar

  The file must be a jar/aar containing the top.canyie.pine.* hooking classes."
    fi
fi

# ── Check source files ─────────────────────────────────────────────────────
SRC_DIR="$SCRIPT_DIR/src/com/dhuadapter"
JAVA_FILES=("$SRC_DIR"/*.java)
if [[ ! -f "${JAVA_FILES[0]}" ]]; then
    die "No Java sources found in $SRC_DIR"
fi

info "Found ${#JAVA_FILES[@]} Java source file(s)"

# ── Clean & prepare build directory ────────────────────────────────────────
info "Preparing build directory..."
# Targeted cleanup (avoid rm -rf which is policy-blocked)
find build/classes -mindepth 1 -delete 2>/dev/null || true
find build/smali -mindepth 1 -delete 2>/dev/null || true
rm -f build/classes.dex build/classes_dhu.dex
mkdir -p build/classes build/smali

# ── Step 1: Compile Java → .class ─────────────────────────────────────────
info "Compiling Java sources..."
CLASSPATH="$PLATFORM:$PINE_JAR"
# Collect all .java files recursively under src/
SOURCES=()
while IFS= read -r -d '' f; do
    SOURCES+=("$f")
done < <(find src -name '*.java' -print0)

# Compile. javac prints an unconditional "Note: ... deprecated API" summary that
# no flag suppresses — the deprecated Android APIs we use (NetworkInfo,
# PackageInfo.signatures, setSystemUiVisibility, readParcelable, onBackPressed…)
# are all intentional legacy calls. Drop just those two Note lines; keep errors.
javac \
    --release 11 \
    -cp "$CLASSPATH" \
    -d build/classes \
    "${SOURCES[@]}" 2> >(grep -vE '^Note: (Some input files use or override|Recompile with -Xlint)' >&2)

CLASS_COUNT=$(find build/classes -name '*.class' | wc -l | tr -d ' ')
ok "Compiled $CLASS_COUNT class file(s)"

# ── Step 2: Dex (.class → .dex) ──────────────────────────────────────────
info "Dexing with d8..."

# Collect all .class files
CLASS_FILES=()
while IFS= read -r -d '' f; do
    CLASS_FILES+=("$f")
done < <(find build/classes -name '*.class' -print0)

"$BUILD_TOOLS/d8" \
    --min-api 28 \
    --lib "$PLATFORM" \
    --output build/ \
    "${CLASS_FILES[@]}" \
    "$PINE_JAR"

[[ -f build/classes.dex ]] || die "d8 did not produce build/classes.dex"
mv build/classes.dex build/classes_dhu.dex
ok "Produced build/classes_dhu.dex"

# ── Step 3: Baksmali (dex → smali) ───────────────────────────────────────
info "Disassembling dex to smali..."
$BAKSMALI d build/classes_dhu.dex -o build/smali/
SMALI_COUNT=$(find build/smali -name '*.smali' | wc -l | tr -d ' ')
ok "Produced $SMALI_COUNT smali file(s) in build/smali/"

# ── Step 3b: Swap d8's Pine with the ORIGINAL Pine smali + reassemble ─────
# d8 produced its own Pine bytecode from pine.jar, but the Pine hook engine
# needs the ORIGINAL Pine smali (dex2jar-converted Pine breaks the LibLoader
# interface -> IncompatibleClassChangeError). We keep a vendored copy at
# vendor/pine-smali/top so a /tmp cleanup never breaks the build.
PINE_SMALI="$SCRIPT_DIR/vendor/pine-smali/top"
NEED_REASM=0
if [[ -d "$PINE_SMALI" ]]; then
    info "Swapping in original Pine smali from vendor/pine-smali/top..."
    find build/smali/top -name '*.smali' -delete 2>/dev/null || true
    [[ -d build/smali/top ]] && rmdir build/smali/top 2>/dev/null || true
    cp -r "$PINE_SMALI" build/smali/top
    PINE_COUNT=$(find build/smali/top -name '*.smali' | wc -l | tr -d ' ')
    ok "Pine smali swapped ($PINE_COUNT files)"
    NEED_REASM=1
else
    warn "vendor/pine-smali/top not found — build/classes_dhu.dex keeps d8 Pine"
    warn "(hooks may fail at runtime; restore vendor/pine-smali/top)"
fi

# NOTE: the vendored Zeekr MediaCenter SDK smali is no longer merged — MediaBridge
# now speaks raw Binder directly (see src/.../mediabridge/MediaBridge.java) and
# references the Zeekr interfaces only as string descriptors, so no SDK classes
# are compiled or dexed.

if [[ "$NEED_REASM" == "1" ]]; then
    info "Reassembling to build/classes_dhu.dex..."
    $SMALI a build/smali -o build/classes_dhu.dex
    [[ -f build/classes_dhu.dex ]] || die "smali reassembly failed"
    ok "Reassembled build/classes_dhu.dex (Pine)"
fi

# ── Step 4: Copy native libs (if present) ────────────────────────────────
NATIVE_SRC="$SCRIPT_DIR/native"
if [[ -d "$NATIVE_SRC" ]]; then
    info "Staging native libraries..."
    mkdir -p build/lib
    for arch_dir in "$NATIVE_SRC"/*/; do
        arch="$(basename "$arch_dir")"
        mkdir -p "build/lib/$arch"
        cp "$arch_dir"/*.so "build/lib/$arch/" 2>/dev/null || true
        so_count=$(find "build/lib/$arch" -name '*.so' | wc -l | tr -d ' ')
        info "  $arch: $so_count .so file(s)"
    done
    ok "Native libs staged in build/lib/"
else
    warn "No native/ directory — skipping .so staging"
    warn "If using Pine JNI, place libpine.so in native/arm64-v8a/ and/or native/armeabi-v7a/"
fi

# ── Summary ───────────────────────────────────────────────────────────────
DEX_SIZE=$(stat -f%z build/classes_dhu.dex 2>/dev/null || stat -c%s build/classes_dhu.dex 2>/dev/null || echo "?")
DEX_SIZE_KB=$(echo "scale=1; ${DEX_SIZE} / 1024" | bc 2>/dev/null || echo "?")

echo ""
printf "${GREEN}╔══════════════════════════════════════════╗${NC}\n"
printf "${GREEN}║  DHU Adapter build complete!             ║${NC}\n"
printf "${GREEN}╚══════════════════════════════════════════╝${NC}\n"
echo ""
info "Artifacts:"
info "  build/classes_dhu.dex  — ${DEX_SIZE_KB} KB dex for reference"
info "  build/smali/           — smali tree for injection ($SMALI_COUNT files)"
[[ -d build/lib ]] && info "  build/lib/             — native .so libraries"
echo ""
info "Next: ./patch_apk.sh <target.apk>"
