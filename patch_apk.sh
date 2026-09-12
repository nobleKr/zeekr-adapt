#!/usr/bin/env bash
#
# patch_apk.sh — Inject DHU Adapter framework into an Android APK
#
# Supports both regular APKs and XAPK (split APK bundles).
# Uses DIRECT DEX INJECTION (no apktool recompile) to preserve binary resources.
#
# Usage:
#   ./patch_apk.sh <input.apk|input.xapk> [output] [--config config.json]
#
#   For APK:  output defaults to <name>_dhu_adapted.apk
#   For XAPK: output defaults to <name>_dhu_adapted/ directory with patched splits
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
ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [[ -z "$ANDROID_HOME" ]]; then
    for cand in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "$HOME/android-sdk" "/usr/lib/android-sdk"; do
        [[ -d "$cand" ]] && { ANDROID_HOME="$cand"; break; }
    done
    ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
fi
BUILD_TOOLS="$ANDROID_HOME/build-tools/36.1.0"
KEYSTORE_DIR="$SCRIPT_DIR/keystore"
KEYSTORE="$KEYSTORE_DIR/dhuadapter.keystore"
KEYSTORE_ALIAS="dhuadapter"
KEYSTORE_PASS="dhuadapter"

DHU_DEX="$SCRIPT_DIR/build/classes_dhu.dex"
PINE_SO="$SCRIPT_DIR/native/arm64-v8a/libpine.so"
PATCH_MANIFEST="$SCRIPT_DIR/patch_manifest.py"

# ── Prerequisite checks ────────────────────────────────────────────────────
check_tool() {
    command -v "$1" &>/dev/null || die "'$1' not found in PATH."
}

check_tool python3
check_tool java
check_tool keytool
[[ -x "$BUILD_TOOLS/zipalign" ]]  || die "zipalign not found at $BUILD_TOOLS/"
[[ -x "$BUILD_TOOLS/apksigner" ]] || die "apksigner not found at $BUILD_TOOLS/"
[[ -f "$DHU_DEX" ]]               || die "DHU Adapter dex not found — run build.sh first"
[[ -f "$PATCH_MANIFEST" ]]        || die "patch_manifest.py not found"

# ── Argument parsing ───────────────────────────────────────────────────────
INPUT=""
OUTPUT=""
CONFIG_JSON=""
MEDIA_BRIDGE=false
# Feature flag overrides (empty = keep base config.json default)
F_NETWORK_BYPASS=""
F_ALLOW_CAPTURE=""
F_FORCE_ORIENTATION=""
F_FULLSCREEN=""
F_DEBUG=""
F_METRICS_DPI=""
F_CONFIG_DPI=""
F_DISPLAY=""
F_ROOT_BYPASS=""
F_EMULATOR_BYPASS=""
F_AUTOMOTIVE_FIX=""
F_SIM_READY=""
F_COPY_SIGN=""
COPY_SIGN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config) CONFIG_JSON="$2"; shift 2 ;;
        --media-bridge) MEDIA_BRIDGE=true; F_MEDIA_BRIDGE=true; shift ;;
        --network-bypass) F_NETWORK_BYPASS=true; shift ;;
        --no-network-bypass) F_NETWORK_BYPASS=false; shift ;;
        --allow-capture) F_ALLOW_CAPTURE=true; shift ;;
        --no-orientation) F_FORCE_ORIENTATION=false; shift ;;
        --no-fullscreen) F_FULLSCREEN=false; shift ;;
        --no-display) F_DISPLAY=false; shift ;;
        --display) F_DISPLAY=true; shift ;;
        --root-bypass) F_ROOT_BYPASS=true; shift ;;
        --no-root-bypass) F_ROOT_BYPASS=false; shift ;;
        --emulator-bypass) F_EMULATOR_BYPASS=true; shift ;;
        --automotive-fix) F_AUTOMOTIVE_FIX=true; shift ;;
        --sim-ready) F_SIM_READY=true; shift ;;
        --copy-sign) F_COPY_SIGN=true; COPY_SIGN=true; shift ;;
        --debug) F_DEBUG=true; shift ;;
        --metrics-dpi) F_METRICS_DPI="$2"; shift 2 ;;
        --config-dpi) F_CONFIG_DPI="$2"; shift 2 ;;
        -h|--help)
            cat <<EOF
Usage: $0 <input.apk|input.xapk> [output] [flags]

Config is BAKED INTO the APK (assets/dhu-adapter-config.json). No external files.
Flags override the defaults from config.json for THIS patch only:

  --media-bridge        Zeekr MediaCenter integration (CoverProvider + register)
                        — media apps only (Spotify/Apple Music/YT Music)
  --network-bypass      force network "online" (DHU Ethernet/TBOX; fixes offline)
  --no-network-bypass   disable network bypass
  --allow-capture       strip FLAG_SECURE so the app's screen can be captured /
                        mirrored where the app blocks it (secure window)
  --no-orientation      don't force landscape
  --no-fullscreen       don't force fullscreen
  --no-display          disable the whole Display/UI category (density, orientation,
                        fullscreen, corners, back button, font, WebView) — bare shell
  --root-bypass         Category 2: hide root/su (Build.TAGS, File.exists, exec,
                        ProcessBuilder, PackageManager, root SystemProperties)
  --emulator-bypass     Category 3: de-genericise Build.* + qemu/goldfish props
                        (only needed when running on an emulator)
  --automotive-fix      Category 4: isAutomotiveOS→false (Waze) + block Android Auto
  --sim-ready           Category 5b: getSimState→READY + key_use_cellular_data=true
                        (Apple Music online-gate; HARMFUL to SIM-aware apps e.g.
                        Telegram phone registration — keep it app-scoped)
  --copy-sign           Category 9: extract the stock APK's GENUINE signer cert
                        from its v2/v3 signing block into assets/orig-cert.der and
                        feed it to the app's signature self-check (Spotify). No
                        hardcoded cert.
  --debug               enable debug logging
  --metrics-dpi <n>     rendering DPI (default 280)
  --config-dpi <n>      layout DPI (default 240)
  --config <file>       use an explicit config.json instead of generating one
EOF
            exit 0 ;;
        -*) die "Unknown option: $1" ;;
        *)
            if [[ -z "$INPUT" ]]; then INPUT="$1"
            elif [[ -z "$OUTPUT" ]]; then OUTPUT="$1"
            else die "Unexpected argument: $1"; fi
            shift ;;
    esac
done

[[ -n "$INPUT" ]] || die "Usage: $0 <input.apk|input.xapk> [output] [flags] (see --help)"
[[ -f "$INPUT" ]] || die "Input not found: $INPUT"
# Absolute path — later steps cd into a temp dir, so a relative INPUT would break.
INPUT="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
[[ -z "$CONFIG_JSON" || -f "$CONFIG_JSON" ]] || die "Config not found: $CONFIG_JSON"

# ── Generate embedded config from base config.json + flag overrides ─────────
# (unless an explicit --config file was given)
if [[ -z "$CONFIG_JSON" ]]; then
    BASE_CONFIG="$SCRIPT_DIR/config.json"
    [[ -f "$BASE_CONFIG" ]] || die "Base config not found: $BASE_CONFIG"
    GEN_CONFIG="$(mktemp -t dhu-cfg).json"
    MEDIA_BRIDGE_FLAG="$MEDIA_BRIDGE" \
    F_NETWORK_BYPASS="$F_NETWORK_BYPASS" F_ALLOW_CAPTURE="$F_ALLOW_CAPTURE" \
    F_FORCE_ORIENTATION="$F_FORCE_ORIENTATION" F_FULLSCREEN="$F_FULLSCREEN" \
    F_DEBUG="$F_DEBUG" F_METRICS_DPI="$F_METRICS_DPI" F_CONFIG_DPI="$F_CONFIG_DPI" \
    F_DISPLAY="$F_DISPLAY" F_ROOT_BYPASS="$F_ROOT_BYPASS" \
    F_EMULATOR_BYPASS="$F_EMULATOR_BYPASS" F_AUTOMOTIVE_FIX="$F_AUTOMOTIVE_FIX" \
    F_SIM_READY="$F_SIM_READY" \
    F_COPY_SIGN="$F_COPY_SIGN" \
    python3 - "$BASE_CONFIG" "$GEN_CONFIG" <<'PYEOF'
import json, os, sys
base, out = sys.argv[1], sys.argv[2]
c = json.load(open(base))
def setb(env, key):
    v = os.environ.get(env, "")
    if v == "true": c[key] = True
    elif v == "false": c[key] = False
def seti(env, key):
    v = os.environ.get(env, "")
    if v: c[key] = int(v)
if os.environ.get("MEDIA_BRIDGE_FLAG") == "true": c["mediaBridge"] = True
setb("F_NETWORK_BYPASS", "networkBypass")
setb("F_ALLOW_CAPTURE", "allowCapture")
setb("F_FORCE_ORIENTATION", "forceOrientation")
setb("F_FULLSCREEN", "fullscreen")
setb("F_DEBUG", "debug")
setb("F_DISPLAY", "display")
setb("F_ROOT_BYPASS", "rootBypass")
setb("F_EMULATOR_BYPASS", "emulatorBypass")
setb("F_AUTOMOTIVE_FIX", "automotiveFix")
setb("F_SIM_READY", "simReady")
setb("F_COPY_SIGN", "copySign")
seti("F_METRICS_DPI", "metricsDpi")
seti("F_CONFIG_DPI", "configDpi")
json.dump(c, open(out, "w"), indent=2)
print("Generated embedded config:", {k: c.get(k) for k in
      ("display","rootBypass","emulatorBypass","automotiveFix",
       "mediaBridge","networkBypass","simReady","allowCapture","copySign",
       "forceOrientation","fullscreen","debug","metricsDpi","configDpi")})
PYEOF
    CONFIG_JSON="$GEN_CONFIG"
fi

# ── Detect format ──────────────────────────────────────────────────────────
IS_XAPK=false
if [[ "$INPUT" == *.xapk ]]; then
    IS_XAPK=true
    info "Detected XAPK (split APK bundle)"
fi

# Default output
if [[ -z "$OUTPUT" ]]; then
    base="${INPUT%.*}"
    if $IS_XAPK; then
        OUTPUT="${base}_dhu_adapted"
    else
        OUTPUT="${base}_dhu_adapted.apk"
    fi
fi

# ── Temp directory ─────────────────────────────────────────────────────────
TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/dhu-patch.XXXXXX")"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# ── Keystore ───────────────────────────────────────────────────────────────
ensure_keystore() {
    if [[ -f "$KEYSTORE" ]]; then
        return 0   # generate-once: reuse the existing project keystore
    fi
    info "Generating DHUAdapter signing keystore (one-time)..."
    mkdir -p "$KEYSTORE_DIR"
    # Branded identity — a stable, project-owned key (NOT the Android debug key).
    # What matters for the apps is a cryptographically VALID signature, not the
    # identity; this makes patched builds attributable to the project.
    keytool -genkeypair -v \
        -keystore "$KEYSTORE" -alias "$KEYSTORE_ALIAS" \
        -keyalg RSA -keysize 2048 -validity 10950 \
        -storepass "$KEYSTORE_PASS" -keypass "$KEYSTORE_PASS" \
        -dname "CN=DHUAdapter, OU=https://github.com/nobleKr, O=nobleKr, L=zeekr-adapt, C=US" 2>&1 | tail -1
    ok "Keystore created: $KEYSTORE (reused on subsequent builds)"
}

# ── Sign a single APK ─────────────────────────────────────────────────────
sign_apk() {
    local input="$1" output="$2"
    "$BUILD_TOOLS/zipalign" -f -p 4 "$input" "${output}.tmp"
    "$BUILD_TOOLS/apksigner" sign \
        --ks "$KEYSTORE" --ks-pass "pass:$KEYSTORE_PASS" \
        --ks-key-alias "$KEYSTORE_ALIAS" --key-pass "pass:$KEYSTORE_PASS" \
        "${output}.tmp"
    mv "${output}.tmp" "$output"
}

# ── Patch a single base APK (direct injection, no apktool) ────────────────
patch_base_apk() {
    local input="$1" output="$2" inject_pine_so="$3"

    info "Patching manifest (binary AXML)..."
    local provider_args=()
    if [[ "$MEDIA_BRIDGE" == "true" ]]; then
        # authority = <packageName>.dhucovers (CoverProvider exposes album art)
        local pkg
        pkg=$("$BUILD_TOOLS/aapt2" dump packagename "$input" 2>/dev/null | head -1)
        if [[ -z "$pkg" ]]; then
            pkg=$("$BUILD_TOOLS/aapt2" dump badging "$input" 2>/dev/null \
                | sed -n "s/.*package: name='\([^']*\)'.*/\1/p" | head -1)
        fi
        [[ -n "$pkg" ]] || die "Could not determine package name for --media-bridge"
        provider_args=(--provider "com.dhuadapter.mediabridge.CoverProvider" "${pkg}.dhucovers"
                       --queries-package "com.zeekr.mediacenter"
                       --receiver "com.dhuadapter.mediabridge.RecoveryReceiver" "com.dhuadapter.RECOVER")
        info "Media bridge: CoverProvider authority = ${pkg}.dhucovers"
        info "Media bridge: <queries> package visibility = com.zeekr.mediacenter"
        info "Media bridge: RecoveryReceiver action = com.dhuadapter.RECOVER"
    fi
    python3 "$PATCH_MANIFEST" "$input" "$TMPDIR/manifest_patched.apk" \
        "com.dhuadapter.DhuAdapterFactory" ${provider_args[@]+"${provider_args[@]}"} 2>&1 | grep -v "^$"

    cd "$TMPDIR"

    # Find next available classesN.dex slot
    local max_n=0
    for dex in $(unzip -l manifest_patched.apk 2>/dev/null | grep -o 'classes[0-9]*\.dex' | sort -u); do
        n="${dex#classes}"
        n="${n%.dex}"
        [[ -z "$n" ]] && n=1
        (( n > max_n )) && max_n=$n
    done
    local next_n=$(( max_n + 1 ))
    local dex_name="classes${next_n}.dex"
    info "Injecting DHU Adapter as $dex_name"

    cp "$DHU_DEX" "$dex_name"
    zip -0 manifest_patched.apk "$dex_name" 2>&1

    # Inject config if provided
    if [[ -n "$CONFIG_JSON" ]]; then
        mkdir -p assets
        cp "$CONFIG_JSON" assets/dhu-adapter-config.json
        zip -0 manifest_patched.apk assets/dhu-adapter-config.json 2>&1
        ok "Config embedded"
    fi

    # --copy-sign (Category 9): extract the stock APK's GENUINE signer cert from
    # its v2/v3 APK Signing Block and stash it as assets/orig-cert.der. The
    # runtime SignatureSpoof hook feeds it back to the app's signature self-check.
    # No cert bytes hardcoded. Modern APKs ship no v1/.RSA, so we parse v2/v3.
    if [[ "$COPY_SIGN" == "true" ]]; then
        mkdir -p assets
        if python3 "$SCRIPT_DIR/tools/extract_apk_cert.py" "$INPUT" assets/orig-cert.der 2>/dev/null; then
            zip -0 manifest_patched.apk assets/orig-cert.der 2>&1
            ok "copy-sign: genuine cert preserved → assets/orig-cert.der ($(wc -c < assets/orig-cert.der | tr -d ' ') bytes)"
        else
            warn "--copy-sign: could not extract signer cert from input (v1-only/unsigned?) — signature spoof will no-op"
        fi
    fi

    # Inject libpine.so into base (for non-split APKs)
    if [[ "$inject_pine_so" == "true" && -f "$PINE_SO" ]]; then
        mkdir -p lib/arm64-v8a
        cp "$PINE_SO" lib/arm64-v8a/
        zip -0 manifest_patched.apk lib/arm64-v8a/libpine.so 2>&1
        ok "libpine.so injected into base"
    fi

    ok "Dex injected as $dex_name"

    ensure_keystore
    sign_apk manifest_patched.apk "$output"
    ok "Base APK patched and signed"
}

# ── Inject libpine.so into an arm64 split APK ─────────────────────────────
inject_pine_into_split() {
    local input="$1" output="$2"
    cp "$input" "$TMPDIR/split_pine.apk"
    cd "$TMPDIR"
    mkdir -p lib/arm64-v8a
    cp "$PINE_SO" lib/arm64-v8a/
    zip -0 split_pine.apk lib/arm64-v8a/libpine.so 2>&1
    sign_apk split_pine.apk "$output"
    ok "libpine.so injected into arm64 split"
}

# ── Re-sign a split APK (no modifications) ────────────────────────────────
resign_split() {
    local input="$1" output="$2"
    sign_apk "$input" "$output"
}

# ════════════════════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════════════════════

if ! $IS_XAPK; then
    # ── Regular APK ────────────────────────────────────────────────────────
    info "Patching APK: $(basename "$INPUT")"
    patch_base_apk "$INPUT" "$OUTPUT" "true"

    size=$(stat -f%z "$OUTPUT" 2>/dev/null || stat -c%s "$OUTPUT")
    size_mb=$(echo "scale=2; $size / 1048576" | bc)

    echo ""
    printf "${GREEN}╔══════════════════════════════════════════╗${NC}\n"
    printf "${GREEN}║  DHU Adapter patching complete!          ║${NC}\n"
    printf "${GREEN}╚══════════════════════════════════════════╝${NC}\n"
    echo ""
    info "Output: $OUTPUT ($size_mb MB)"
    info "Install: adb install -r \"$OUTPUT\""
else
    # ── XAPK (split APK bundle) ───────────────────────────────────────────
    info "Processing XAPK: $(basename "$INPUT")"
    XAPK_DIR="$TMPDIR/xapk"
    mkdir -p "$XAPK_DIR"
    unzip -o "$INPUT" -d "$XAPK_DIR" 2>&1 | tail -1

    # Preserve original icon if present
    ORIG_ICON="$XAPK_DIR/icon.png"

    # Find base APK
    BASE_APK=""
    ARM64_SPLIT=""
    OTHER_SPLITS=()

    for apk in "$XAPK_DIR"/*.apk; do
        name="$(basename "$apk")"
        case "$name" in
            *base*|com.*.apk)
                # Heuristic: base is the package-named one or contains 'base'
                if [[ -z "$BASE_APK" ]]; then
                    BASE_APK="$apk"
                else
                    OTHER_SPLITS+=("$apk")
                fi ;;
            *arm64*)
                ARM64_SPLIT="$apk" ;;
            *)
                OTHER_SPLITS+=("$apk") ;;
        esac
    done

    [[ -n "$BASE_APK" ]] || die "Could not find base APK in XAPK"
    info "Base APK: $(basename "$BASE_APK")"

    # Create output directory
    mkdir -p "$OUTPUT"

    # Patch base (do NOT inject pine.so — it goes in arm64 split)
    patch_base_apk "$BASE_APK" "$OUTPUT/base.apk" "false"

    # Handle arm64 split (inject libpine.so)
    if [[ -n "$ARM64_SPLIT" ]]; then
        info "Arm64 split: $(basename "$ARM64_SPLIT") — injecting libpine.so"
        inject_pine_into_split "$ARM64_SPLIT" "$OUTPUT/$(basename "$ARM64_SPLIT")"
    elif [[ -f "$PINE_SO" ]]; then
        warn "No arm64 split found — libpine.so NOT injected!"
        warn "Pine hooks will fail to load at runtime."
    fi

    # Re-sign other splits
    for split in "${OTHER_SPLITS[@]}"; do
        name="$(basename "$split")"
        info "Re-signing split: $name"
        resign_split "$split" "$OUTPUT/$name"
    done

    # Pack into .xapk file
    XAPK_OUT="${OUTPUT%.xapk}"
    XAPK_OUT="${XAPK_OUT%/}"
    XAPK_FILE="${XAPK_OUT}.xapk"

    # Extract package metadata from base.apk via aapt2
    # badging
    badging=$("$BUILD_TOOLS/aapt2" dump badging "$OUTPUT/base.apk" 2>/dev/null)
    # pkg_name version_code version_name min_sdk target_sdk app_name

    pkg_name=$(echo "$badging" | grep "^package:" | head -1 | sed "s/^package: name='//;s/' .*//")
    version_code=$(echo "$badging" | grep "^package:" | head -1 | sed "s/.*versionCode='//;s/' .*//;s/'.*//")
    version_name=$(echo "$badging" | grep "^package:" | head -1 | sed "s/.*versionName='//;s/' .*//;s/'.*//")
    min_sdk=$(echo "$badging" | grep -E "^(sdkVersion|minSdkVersion):" | head -1 | sed "s/[^']*'//;s/'.*//")
    target_sdk=$(echo "$badging" | grep "^targetSdkVersion:" | head -1 | sed "s/[^']*'//;s/'.*//")
    app_name=$(echo "$badging" | grep "^application-label:" | head -1 | sed "s/[^']*'//;s/'.*//")
    [[ -z "$app_name" ]] && app_name="$pkg_name"

    # Extract permissions
    perms_json=""
    while IFS= read -r perm; do
        [[ -n "$perms_json" ]] && perms_json+=","
        perms_json+="\"$perm\""
    done < <(echo "$badging" | grep "^uses-permission:" | sed "s/.*name='//;s/'.*//" | sort -u)

    # Rename base.apk to match APKPure convention (package_name.apk)
    if [[ -f "$OUTPUT/base.apk" && "$pkg_name" != "base" ]]; then
        mv "$OUTPUT/base.apk" "$OUTPUT/${pkg_name}.apk"
    fi

    # Calculate total_size and build split_apks/split_configs
    total_size=0
    split_json=""
    configs_json=""
    first_split=true
    first_config=true
    for apk in "$OUTPUT"/*.apk; do
        # name fsize id
        name="$(basename "$apk")"
        fsize=$(stat -f%z "$apk" 2>/dev/null || stat -c%s "$apk")
        total_size=$((total_size + fsize))

        # Determine id
        if [[ "$name" == "${pkg_name}.apk" || "$name" == "base.apk" ]]; then
            id="base"
        else
            id="${name%.apk}"
        fi

        $first_split || split_json+=","
        split_json+="{\"file\":\"$name\",\"id\":\"$id\"}"
        first_split=false

        # Add to split_configs (skip base)
        if [[ "$id" != "base" ]]; then
            $first_config || configs_json+=","
            configs_json+="\"$id\""
            first_config=false
        fi
    done

    # Add icon size to total
    if [[ -f "$OUTPUT/icon.png" ]]; then
        # icon_size
        icon_size=$(stat -f%z "$OUTPUT/icon.png" 2>/dev/null || stat -c%s "$OUTPUT/icon.png")
        total_size=$((total_size + icon_size))
    fi

    # Build full manifest.json (APKPure-compatible format)
    cat > "$OUTPUT/manifest.json" << MANIFEST_EOF
{
  "xapk_version": 2,
  "package_name": "$pkg_name",
  "name": "$app_name",
  "version_code": "$version_code",
  "version_name": "$version_name",
  "min_sdk_version": "${min_sdk:-28}",
  "target_sdk_version": "${target_sdk:-34}",
  "permissions": [$perms_json],
  "split_configs": [$configs_json],
  "total_size": $total_size,
  "icon": "icon.png",
  "split_apks": [$split_json]
}
MANIFEST_EOF

    info "Manifest: $pkg_name v$version_name (code=$version_code, size=$(echo "scale=1; $total_size/1048576" | bc)MB)"

    # Zip into .xapk
    info "Packing into $(basename "$XAPK_FILE")..."
    # Copy icon from original XAPK if available
    if [[ -f "$ORIG_ICON" ]]; then
        cp "$ORIG_ICON" "$OUTPUT/icon.png"
    fi
    cd "$OUTPUT"
    # Include all APKs, manifest, and icon
    zip_files=()
    for f in *.apk manifest.json; do
        [[ -f "$f" ]] && zip_files+=("$f")
    done
    [[ -f icon.png ]] && zip_files+=("icon.png")
    zip -0 "$XAPK_FILE" "${zip_files[@]}" 2>&1 | tail -1
    cd - >/dev/null

    xapk_size=$(stat -f%z "$XAPK_FILE" 2>/dev/null || stat -c%s "$XAPK_FILE")
    xapk_mb=$(echo "scale=2; $xapk_size / 1048576" | bc)

    echo ""
    printf "${GREEN}╔══════════════════════════════════════════╗${NC}\n"
    printf "${GREEN}║  DHU Adapter XAPK patching complete!     ║${NC}\n"
    printf "${GREEN}╚══════════════════════════════════════════╝${NC}\n"
    echo ""
    info "Output: $XAPK_FILE ($xapk_mb MB)"
    info "Install: adb install-multiple $OUTPUT/*.apk"
fi
