#!/bin/zsh

set -euo pipefail

BUILD_DIR="$(pwd)/build"
PRODUCTS_DIR="$BUILD_DIR/Build/Products/Debug"

echo "➡️  Building QuizCLIApp…"
xcodebuild \
  -workspace QuizEngine.xcworkspace \
  -scheme QuizCLIApp \
  -destination 'platform=macOS' \
  -derivedDataPath "$BUILD_DIR" \
  build >/tmp/quizcli-build.log

echo "✅ Build succeeded."
echo "➡️  Launching QuizCLIApp…"

export DYLD_FRAMEWORK_PATH="$PRODUCTS_DIR"
exec "$PRODUCTS_DIR/QuizCLIApp"
