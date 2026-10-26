# Borrón

Metroidvania 2D dibujado a mano sobre una gota de Tinta con conciencia propia.
Diseño: `docs/superpowers/specs/2026-10-25-borron-design.md`

## Cómo jugarlo

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

## Desarrollo

- `./tools/install_godot.sh` instala Godot (Linux) para ejecutar pruebas sin pantalla.
- `./tools/test.sh` ejecuta todas las pruebas automáticas (GUT).
