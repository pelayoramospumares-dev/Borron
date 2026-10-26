#!/usr/bin/env bash
# Descarga Godot (editor, Linux x86_64) en la versión fijada en GODOT_VERSION.
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="$(cat GODOT_VERSION)"
DEST="${HOME}/.local/bin"
mkdir -p "$DEST"
if command -v godot >/dev/null && godot --version 2>/dev/null | grep -q "^${VERSION}.stable"; then
  echo "Godot ${VERSION} ya instalado"; exit 0
fi
TMP="$(mktemp -d)"
curl -sSL -o "$TMP/godot.zip" \
  "https://github.com/godotengine/godot/releases/download/${VERSION}-stable/Godot_v${VERSION}-stable_linux.x86_64.zip"
unzip -q -o "$TMP/godot.zip" -d "$TMP"
mv "$TMP/Godot_v${VERSION}-stable_linux.x86_64" "$DEST/godot"
chmod +x "$DEST/godot"
rm -rf "$TMP"
"$DEST/godot" --version
