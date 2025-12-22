#!/usr/bin/env bash
set -euo pipefail

APP_NAME="mixgen"
PREFIX="${PREFIX:-$HOME/.local}"
TARGET_DIR="$PREFIX/bin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$TARGET_DIR"
install -m 755 "$SCRIPT_DIR/mixgen.sh" "$TARGET_DIR/$APP_NAME"

echo "Installed $APP_NAME to $TARGET_DIR/$APP_NAME"

if ! echo "$PATH" | tr ':' '\n' | grep -Fxq "$TARGET_DIR"; then
  echo "Add $TARGET_DIR to your PATH (e.g., export PATH=\"$TARGET_DIR:\$PATH\")"
fi
