#!/usr/bin/env bash
#
# Pure-logic JVM unit tests — no Gradle, no JUnit, no android.jar, no Pine.
# Compiles only the dependency-free decision classes plus the test runner on a
# bare JDK and executes them. Exits non-zero if any assertion fails, so it is
# usable as a CI gate. See .github/workflows/tests.yml.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

command -v javac >/dev/null 2>&1 || { echo "javac not found on PATH"; exit 2; }
command -v java  >/dev/null 2>&1 || { echo "java not found on PATH";  exit 2; }

echo "Using: $(javac -version 2>&1)"

OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

# Sources under test MUST be dependency-free (no android.* / Pine imports) so
# they compile and run on a plain JDK. Keep this list in sync as pure logic is
# extracted.
SRCS=(
    src/com/dhuadapter/core/TransformRegistry.java
    src/com/dhuadapter/root/RootPathMatcher.java
    src/com/dhuadapter/sysprops/PropSpoofTable.java
    src/com/dhuadapter/signature/CertReader.java
    test/com/dhuadapter/PureLogicTests.java
)

echo "Compiling ${#SRCS[@]} source file(s)..."
javac -Xlint:all -d "$OUT" "${SRCS[@]}"

echo "Running com.dhuadapter.PureLogicTests..."
java -cp "$OUT" com.dhuadapter.PureLogicTests
