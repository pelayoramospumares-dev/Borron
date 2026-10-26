#!/usr/bin/env bash
# Renderiza una escena de captura con pantalla virtual. Uso: tools/capture.sh <escena.tscn> <salida>
set -uo pipefail
cd "$(dirname "$0")/.."
export PATH="$HOME/.local/bin:$PATH"
godot --headless --path . --import >/dev/null 2>&1
timeout 180 xvfb-run -a -s "-screen 0 1920x1080x24" godot --path . --rendering-driver opengl3 \
  --resolution 1920x1080 "res://$1" -- --out="$2" 2>&1 | grep -E "captura|ERROR|SCRIPT" | grep -v -E "ALSA|audio"
