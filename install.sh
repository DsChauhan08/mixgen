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
OLD_UMASK=$(umask)
umask 077
TMP_FILE="$(mktemp -t mixgen.XXXXXXXXXXXX)"
umask "$OLD_UMASK"
trap 'rm -f "$TMP_FILE"' EXIT

echo "Downloading latest $APP_NAME release..."
if curl -fsSL -o "$TMP_FILE" "$LATEST_RELEASE_URL"; then
  echo "Downloaded from latest release."
else
  STATUS=$?
  echo "Failed to download from latest release (curl exit $STATUS). Falling back to main branch download..."
  if ! curl -fsSL -o "$TMP_FILE" "$FALLBACK_URL"; then
    echo "Failed to download $APP_NAME from release or main branch."
    exit 1
  fi
fi

if [ ! -s "$TMP_FILE" ]; then
  echo "Downloaded $APP_NAME script is empty."
  exit 1
fi

FIRST_LINE="$(head -n 1 "$TMP_FILE")"
SHELL_BIN=""
case "$FIRST_LINE" in
  "#!/bin/sh" | "#!/usr/bin/sh")
    SHELL_BIN="${FIRST_LINE#\#!}"
    ;;
  "#!/usr/bin/env sh")
    SHELL_BIN="$(command -v sh || true)"
    ;;
  "#!/bin/bash" | "#!/usr/bin/bash" | "#!/usr/local/bin/bash" | "#!/usr/bin/env bash")
    SHELL_BIN="${FIRST_LINE#\#!}"
    if [ "$FIRST_LINE" = "#!/usr/bin/env bash" ]; then
      SHELL_BIN="$(command -v bash || true)"
    fi
    ;;
  *)
    echo "Downloaded $APP_NAME script has invalid shebang: $FIRST_LINE"
    exit 1
    ;;
esac

if [ -z "$SHELL_BIN" ] || [ ! -x "$SHELL_BIN" ]; then
  echo "Required shell interpreter not found for shebang: $FIRST_LINE"
  exit 1
fi

install -m 755 "$TMP_FILE" "$TARGET_DIR/$APP_NAME"

echo "Installed $APP_NAME to $TARGET_DIR/$APP_NAME"

if ! echo "$PATH" | tr ':' '\n' | grep -Fxq "$TARGET_DIR"; then
  echo "Add $TARGET_DIR to your PATH (e.g., export PATH=\"$TARGET_DIR:\$PATH\")"
fi
