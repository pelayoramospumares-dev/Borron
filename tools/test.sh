#!/usr/bin/env bash
# Ejecuta todas las pruebas GUT sin pantalla. Uso: ./tools/test.sh [-gselect=test_x.gd]
# Falla si alguna prueba falla o si algún script no compila.
set -uo pipefail
cd "$(dirname "$0")/.."
export PATH="$HOME/.local/bin:$PATH"
godot --headless --path . --import >/dev/null 2>&1
out="$(mktemp)"
timeout 900 godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit "$@" 2>&1 | tee "$out"
rc=${PIPESTATUS[0]}
if grep -qE "SCRIPT ERROR|Parse Error" "$out"; then
  echo "test.sh: errores de script detectados"; rc=1
fi
if ! grep -q "All tests passed" "$out"; then rc=1; fi
rm -f "$out"
exit $rc
