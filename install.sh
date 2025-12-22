#!/usr/bin/env bash
set -euo pipefail

APP_NAME="mixgen"
PREFIX="${PREFIX:-$HOME/.local}"
TARGET_DIR="$PREFIX/bin"
OWNER="DsChauhan08"
REPO="mixgen"
LATEST_RELEASE_URL="https://github.com/$OWNER/$REPO/releases/latest/download/mixgen.sh"
FALLBACK_URL="https://raw.githubusercontent.com/$OWNER/$REPO/main/mixgen.sh"

mkdir -p "$TARGET_DIR"
TMP_FILE="$(mktemp)"
chmod 600 "$TMP_FILE"

echo "Downloading latest $APP_NAME release..."
if ! curl -fsSL -o "$TMP_FILE" "$LATEST_RELEASE_URL"; then
  echo "Latest release not available yet. Falling back to main branch download..."
  if ! curl -fsSL -o "$TMP_FILE" "$FALLBACK_URL"; then
    echo "Failed to download $APP_NAME from release or main branch."
    exit 1
  fi
fi

install -m 755 "$TMP_FILE" "$TARGET_DIR/$APP_NAME"
rm -f "$TMP_FILE"

echo "Installed $APP_NAME to $TARGET_DIR/$APP_NAME"

if ! echo "$PATH" | tr ':' '\n' | grep -Fxq "$TARGET_DIR"; then
  echo "Add $TARGET_DIR to your PATH (e.g., export PATH=\"$TARGET_DIR:\$PATH\")"
fi
