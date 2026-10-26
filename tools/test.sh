#!/usr/bin/env bash
# Ejecuta todas las pruebas GUT sin pantalla. Uso: ./tools/test.sh [-gselect=test_x.gd]
set -uo pipefail
cd "$(dirname "$0")/.."
export PATH="$HOME/.local/bin:$PATH"
godot --headless --path . --import >/dev/null 2>&1
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit "$@"
