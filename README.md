# Borrón

Metroidvania 2D dibujado a mano sobre una gota de Tinta con conciencia propia.
Diseño: `docs/superpowers/specs/2026-10-25-borron-design.md`

## Cómo jugarlo

### Opción A: sin instalar nada (Windows)
Descomprime `Borron-Windows.zip` y abre `Borron.exe`. Si Windows avisa de que la aplicación no es de confianza, pulsa *Más información → Ejecutar de todas formas* (el ejecutable no está firmado).

### Opción B: con Godot (para ver y tocar el proyecto)
1. Descarga **Godot** en la versión indicada en `GODOT_VERSION` (versión *Standard*, no .NET):
   https://github.com/godotengine/godot/releases (busca `<versión>-stable`).
2. Descomprímelo y ábrelo (no requiere instalación).
3. Pulsa **Importar**, elige el archivo `project.godot` de esta carpeta y ábrelo.
4. Pulsa **F5** (o el botón ▶ arriba a la derecha) para jugar.

## Controles

| Acción | Teclado | Mando |
|---|---|---|
| Moverse | WASD / flechas | Stick izquierdo / cruceta |
| Saltar | Espacio | A |
| Atacar | J (con ↑/↓ para atacar arriba/abajo) | X |
| Dash | K | RB |
| Curarse (mantener) | L | B |
| Forma charco (mantener) | I | LB |
| Interactuar | W / ↑ | Y |
| Pausa | Esc | Start |
| Contador de FPS | F3 | — |

## Prototipo "La Primera Mancha"

- 10 salas en la Zona 1 (*Las Afueras Borradas*), 2 Tinteros, sala secreta y jefe: **El Escriba Hueco**.
- Descansa en un Tintero (pulsa ↑ junto al farol) para guardar y abrir el **Árbol de la Tinta**.
- La forma charco se consigue en el santuario de la sala 6.
- Fondos pintados opcionales: ver `docs/art/prompts.md`.

## Desarrollo

- `./tools/install_godot.sh` instala Godot (Linux) para ejecutar pruebas sin pantalla.
- `./tools/test.sh` ejecuta todas las pruebas automáticas (GUT).
- `./tools/capture.sh <escena> <salida>` renderiza capturas sin pantalla (xvfb); escenas en `tools/capture/`.
- Exportar: `godot --headless --export-release "Windows" export/windows/Borron.exe` (requiere las plantillas de exportación).
