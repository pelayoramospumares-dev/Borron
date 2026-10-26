# Prototipo "La Primera Mancha" — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Objetivo:** construir el Hito 1 de *Borrón*: 15–20 min jugables en la Zona 1 con movimiento líquido, combate con Tinta/Inestabilidad/Desborde, forma charco, 3 enemigos, 1 jefe, Tinteros, mini árbol de 9 nodos y animación/partículas al nivel de calidad objetivo.

**Arquitectura:** proyecto Godot 4 en GDScript tipado. Lógica pura (recursos, árbol, guardado, fórmulas) en clases sin nodos probadas con GUT; el jugador es una máquina de estados con un estado por archivo; sistemas desacoplados vía `EventBus`; valores ajustables en *Resources* `.tres`.

**Tech stack:** Godot 4 (última estable al empezar, fijada en `GODOT_VERSION`), GDScript con tipado estático, GUT 9.x para pruebas, Git.

**Spec:** `docs/superpowers/specs/2026-10-25-borron-design.md`

## Restricciones globales

- Nada de pixel art: resolución base 1920×1080, `stretch/mode = canvas_items`, `stretch/aspect = expand`, filtrado de texturas lineal, sin *pixel snap*.
- Fluidez: `physics/common/physics_ticks_per_second = 120`, `physics/common/physics_interpolation = true`, FPS sin límite, V-Sync activado por defecto (configurable más adelante).
- HDR 2D activado (`rendering/viewport/hdr_2d = true`) y *glow* mediante `WorldEnvironment`.
- Todo GDScript con tipado estático (`var x: float`, firmas tipadas); warnings de tipos no tipados como error.
- Identificadores de código en inglés; textos visibles al jugador en español, a través de `tr()` con claves.
- Los valores ajustables (movimiento, tinta, enemigos, nodos) viven en `.tres`, nunca como números mágicos en el código.
- Guardado en `user://save_<slot>.json`, escritura atómica (temporal + renombrar), campo `"version": 1`.
- Capas de colisión: 1 `world`, 2 `player`, 3 `enemies`, 4 `player_attack`, 5 `enemy_attack`, 6 `grates` (el jugador choca salvo en charco), 7 `hazards`, 8 `interactables`.
- Entrada: `move_left/right/up/down` (WASD + flechas + stick izq. + cruceta), `jump` (Espacio / A), `attack` (J / X), `dash` (K / RB), `heal` (L / B, mantener), `puddle` (I / LB), `interact` (W o ↑ / Y), `pause` (Esc / Start), `debug_fps` (F3).
- Prototipo: un único slot de guardado (`slot = 0`).

## Comando de pruebas

`./tools/test.sh` → ejecuta `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`. Éxito = sale con código 0 y la línea `All tests passed`.

## Review Focus

1. **Guardado ausente, corrupto o de otra versión** → el juego arranca una partida nueva sin cerrarse y avisa por log. *(Prueba en Tarea 2.)*
2. **Salir de la forma charco dentro de una rejilla o hueco bajo** → no se permite; el jugador sigue en charco hasta tener espacio. *(Prueba en Tarea 6.)*
3. **Morir durante el Desborde o la vulnerabilidad posterior** → al reaparecer, Inestabilidad = 0, sin Desborde ni vulnerabilidad residual. *(Prueba en Tarea 5.)*
4. **Pantallas no 16:9 (ultrapanorámicas, 16:10, ventana redimensionada)** → no se ven bordes fuera de la sala; la cámara respeta los límites. *(Prueba en Tarea 8.)*
5. **Comprar un nodo sin Recuerdos suficientes, sin su prerrequisito o ya comprado** → se rechaza y no se descuenta nada. *(Prueba en Tarea 3.)*

---

## Estructura de archivos

```
borron/
├── project.godot, GODOT_VERSION, README.md, .gitignore, export_presets.cfg
├── tools/install_godot.sh, tools/test.sh
├── addons/gut/
├── autoload/   event_bus.gd, game_state.gd, save_manager.gd, hit_stop.gd
├── components/ health.gd, hitbox.gd, hurtbox.gd, ink_meter.gd, ink_config.gd
├── skills/     skill_node.gd, skill_tree.gd, stat_mods.gd, nodes/*.tres
├── player/     player.gd, player.tscn, movement_config.gd, movement_config.tres,
│               movement_math.gd, state_machine.gd, states/*.gd,
│               body/ink_body.gd, body/ink_body.gdshader, body/drip_chain.gd
├── enemies/    enemy_base.gd, enemy_stats.gd, crawler/, flyer/, spitter/
├── bosses/     scribe/  (jefe de la Zona 1)
├── world/      room.gd, room_transition.gd, tintero.gd, recuerdo.gd, grate.gd,
│               ability_shrine.gd, world.gd, world.tscn, zone1/r01..r10.tscn
├── vfx/        game_camera.gd, particles/*.tscn, splatter_decals.gd, drop_texture.gd
├── ui/         hud.tscn/gd, pause_menu.tscn/gd, skill_tree_ui.tscn/gd, fps_counter.gd
├── art/        backgrounds/zone1/, parallax_background.gd
├── docs/art/prompts.md
└── tests/      test_*.gd, scenes/test_room.tscn
```

---

### Tarea 0: Base del proyecto, Godot headless y GUT

**Archivos:**
- Crear: `tools/install_godot.sh`, `tools/test.sh`, `GODOT_VERSION`, `project.godot`, `.gitignore`, `README.md`, `addons/gut/` (descargado), `tests/test_sanity.gd`

**Interfaces:**
- Produce: `./tools/test.sh` (usado por todas las tareas); acciones de entrada y capas de colisión de *Restricciones globales* definidas en `project.godot`.

- [ ] **Paso 1:** `tools/install_godot.sh` descarga la última versión estable de Godot 4 (Linux x86_64, editor) desde las *releases* de GitHub `godotengine/godot`, la instala en `~/.local/bin/godot` y escribe la versión exacta en `GODOT_VERSION`. Ejecutarlo; esperado: `godot --version` imprime esa versión.
- [ ] **Paso 2:** descargar la versión de GUT compatible con esa versión de Godot en `addons/gut/` y activar el plugin en `project.godot`.
- [ ] **Paso 3:** escribir `project.godot` con todos los ajustes de *Restricciones globales* (resolución, estiramiento, ticks, interpolación, HDR 2D, capas, InputMap con teclado y mando), `.gitignore` (`.godot/`, `*.import` no; `export/`), y `tools/test.sh`.
- [ ] **Paso 4: prueba**
```gdscript
# tests/test_sanity.gd
extends GutTest
func test_physics_settings():
    assert_eq(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"), 120)
    assert_true(ProjectSettings.get_setting("physics/common/physics_interpolation"))
    assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 1920)
func test_input_actions_exist():
    for a in ["move_left","move_right","move_up","move_down","jump","attack","dash","heal","puddle","interact","pause","debug_fps"]:
        assert_true(InputMap.has_action(a), a)
```
- [ ] **Paso 5:** `./tools/test.sh` → esperado: `All tests passed`.
- [ ] **Paso 6:** `README.md` con: cómo descargar Godot (versión de `GODOT_VERSION`), abrir el proyecto y pulsar F5; controles.
- [ ] **Paso 7: commit** `chore: scaffold Godot project with GUT and test runner`

---

### Tarea 1: Componentes de vida, golpes y Tinta

**Archivos:**
- Crear: `components/health.gd`, `components/hitbox.gd`, `components/hurtbox.gd`, `components/ink_config.gd`, `components/ink_meter.gd`, `components/ink_config.tres`, `autoload/event_bus.gd`
- Pruebas: `tests/test_health.gd`, `tests/test_ink_meter.gd`

**Interfaces:**
- Produce:
  - `class_name Health extends RefCounted`: `max_hp: float`, `hp: float`, `damage_taken_mult: float = 1.0`, `func take_damage(amount: float) -> float` (devuelve daño real), `func heal(amount: float) -> void`, `func reset() -> void`, `func is_dead() -> bool`, señales `damaged(amount: float)`, `died()`.
  - `class_name InkConfig extends Resource` con los valores de abajo.
  - `class_name InkMeter extends RefCounted`: `ink: float`, `instability: float`, `state: int` (`enum State { NORMAL, OVERFLOW, VULNERABLE }`), `func gain(amount: float) -> void`, `func try_spend(amount: float) -> bool`, `func tick(delta: float) -> void`, `func damage_dealt_mult() -> float`, `func damage_taken_mult() -> float`, `func speed_mult() -> float`, `func reset() -> void`, señales `overflow_started()`, `overflow_ended()`, `vulnerability_ended()`. Lee `instability_gain_mult: float = 1.0` y `overflow_duration_bonus: float = 0.0` (los modifica el árbol).
  - `class_name Hitbox extends Area2D` (`damage: float`, `knockback: float`, `source: Node`); `class_name Hurtbox extends Area2D` con señal `hit(hitbox: Hitbox)` e `invulnerable: bool`.
  - Autoload `EventBus` con señales: `player_died()`, `player_respawned()`, `enemy_killed(enemy: Node)`, `boss_defeated(boss_id: StringName)`, `recuerdos_changed(total: int)`, `ability_unlocked(id: StringName)`, `rested_at_tintero(tintero_id: StringName)`, `hit_landed(position: Vector2, strength: float)`.

**Valores de `ink_config.tres`** (de la spec §4.2): `max_ink = 100`, `ink_per_hit = 12`, `heal_cost = 33`, `heal_amount = 25`, `heal_time = 0.8`, `instability_threshold = 60` (con tinta ≥ umbral la Inestabilidad sube `instability_rise_per_sec = 10`), `instability_decay_per_sec = 8` (por debajo del umbral), `spend_instability_reduction = 0.5` (gastar X tinta resta X·0.5 de Inestabilidad), `overflow_duration = 6.0`, `overflow_damage_mult = 1.75`, `overflow_speed_mult = 1.2`, `vulnerable_duration = 3.0`, `vulnerable_damage_taken_mult = 1.5`. Fuera del Desborde: `damage_dealt_mult = 1 + 0.5·inst/100`, `damage_taken_mult = 1 + 0.5·inst/100`, `speed_mult = 1 + 0.15·inst/100`. Al empezar el Desborde, `ink = 0`; al terminar, `instability = 0`. Durante VULNERABLE no se gana tinta.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
# tests/test_health.gd
func test_damage_with_mult():
    var h := Health.new(); h.max_hp = 100; h.reset(); h.damage_taken_mult = 1.5
    assert_eq(h.take_damage(20), 30.0); assert_eq(h.hp, 70.0)
func test_heal_clamps():  # hp no supera max_hp
func test_died_emits_once():  # dos golpes letales → died emitida 1 vez
# tests/test_ink_meter.gd
func test_gain_clamps_to_max():  # gain(500) → ink == 100
func test_instability_rises_above_threshold():  # ink=60, tick(1.0) → instability == 10
func test_instability_decays_below_threshold():  # ink=0, instability=20, tick(1.0) → 12
func test_spend_reduces_instability():  # ink=100, inst=50, try_spend(33) → true, inst == 33.5
func test_spend_fails_when_insufficient():  # ink=10, try_spend(33) → false, ink == 10
func test_overflow_cycle():  # inst llega a 100 → OVERFLOW, ink 0, mult daño 1.75; tick(6) → VULNERABLE, taken 1.5; tick(3) → NORMAL, inst 0
func test_no_gain_while_vulnerable():
func test_overflow_bonus_extends_duration():  # overflow_duration_bonus=3 → sigue en OVERFLOW tras tick(8)
```
- [ ] **Paso 2:** `./tools/test.sh` → FALLA (clases no definidas).
- [ ] **Paso 3:** implementar las clases con las firmas de arriba. `Hitbox`/`Hurtbox` sin pruebas unitarias aquí (se prueban en la Tarea 5).
- [ ] **Paso 4:** `./tools/test.sh` → PASA.
- [ ] **Paso 5: commit** `feat: health, hitbox/hurtbox, ink meter and event bus`

---

### Tarea 2: Estado de partida y guardado

**Archivos:**
- Crear: `autoload/game_state.gd`, `autoload/save_manager.gd`
- Pruebas: `tests/test_save_manager.gd`

**Interfaces:**
- Consume: `EventBus`.
- Produce:
  - Autoload `GameState`: `recuerdos: int`, `abilities: Array[StringName]`, `purchased_skills: Array[StringName]`, `bosses_defeated: Array[StringName]`, `collected_pickups: Array[StringName]`, `last_tintero: StringName`, `last_room: StringName`; `func has_ability(id: StringName) -> bool`, `func unlock_ability(id: StringName) -> void`, `func add_recuerdos(n: int) -> void` (emite `recuerdos_changed`), `func to_dict() -> Dictionary`, `func from_dict(d: Dictionary) -> void`, `func reset() -> void`.
  - Autoload `SaveManager`: `const VERSION := 1`, `var save_dir := "user://"` (sobrescribible en pruebas), `func save(slot: int) -> bool`, `func load(slot: int) -> bool` (devuelve `false` y llama a `GameState.reset()` si falta, está corrupto o `version` ≠ `VERSION`; registra un `push_warning`), `func has_save(slot: int) -> bool`.

- [ ] **Paso 1: pruebas que fallan** (cada prueba usa un `save_dir` temporal propio)
```gdscript
func test_roundtrip():  # recuerdos=7, abilities=[&"puddle"], last_tintero=&"t1" → save(0); reset(); load(0) == true; valores iguales
func test_missing_file_starts_new_game():  # load(0) == false; GameState.recuerdos == 0
func test_corrupt_file_starts_new_game():  # escribir "{no json" → load(0) == false, sin error fatal
func test_wrong_version_starts_new_game():  # escribir {"version": 99} → load(0) == false
func test_atomic_write_leaves_no_tmp():  # tras save(0) no existe save_0.json.tmp
```
- [ ] **Paso 2:** ejecutar → FALLA.
- [ ] **Paso 3:** implementar. Escritura: `save_<slot>.json.tmp` → `DirAccess.rename` a `save_<slot>.json`.
- [ ] **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: commit** `feat: game state and atomic versioned save system`

---

### Tarea 3: Árbol de habilidades (lógica y datos)

**Archivos:**
- Crear: `skills/skill_node.gd`, `skills/stat_mods.gd`, `skills/skill_tree.gd`, `skills/nodes/*.tres` (9)
- Pruebas: `tests/test_skill_tree.gd`

**Interfaces:**
- Consume: `GameState`.
- Produce:
  - `class_name SkillNode extends Resource`: `id: StringName`, `branch: StringName` (`&"forma"|&"marea"|&"voracidad"`), `name_key: String`, `desc_key: String`, `cost: int`, `requires: Array[StringName]`, `requires_ability: StringName` (vacío si no), `mods: Dictionary` (clave de `StatMods` → valor).
  - `class_name StatMods extends RefCounted`: campos con valores neutros `max_hp_bonus := 0.0`, `instability_gain_mult := 1.0`, `heal_time_mult := 1.0`, `dash_distance_mult := 1.0`, `puddle_contact_damage := 0.0`, `dash_refresh_on_hit := false`, `damage_mult := 1.0`, `ink_gain_mult := 1.0`, `overflow_duration_bonus := 0.0`, `attack_range_mult := 1.0`.
  - `class_name SkillTree extends RefCounted`: `func _init(nodes: Array[SkillNode])`, `func can_purchase(id: StringName) -> bool`, `func purchase(id: StringName) -> bool` (descuenta `GameState.recuerdos` y añade a `purchased_skills`), `func compute_mods() -> StatMods`, `static func load_all() -> SkillTree` (carga `skills/nodes/*.tres`).

**Nodos** (`requires` encadena cada rama en orden 1→2→3):

| id | Coste | Efecto (`mods`) | Extra |
|---|---|---|---|
| `forma_1` | 2 | `max_hp_bonus: 20` | |
| `forma_2` | 3 | `instability_gain_mult: 0.7` | |
| `forma_3` | 4 | `heal_time_mult: 0.6` | |
| `marea_1` | 2 | `dash_distance_mult: 1.3` | |
| `marea_2` | 3 | `puddle_contact_damage: 15` | `requires_ability: &"puddle"` |
| `marea_3` | 4 | `dash_refresh_on_hit: true` | |
| `voracidad_1` | 2 | `damage_mult: 1.1`, `ink_gain_mult: 1.25` | |
| `voracidad_2` | 3 | `overflow_duration_bonus: 3.0` | |
| `voracidad_3` | 4 | `attack_range_mult: 1.35` | |

Total: 27 Recuerdos. La Zona 1 contiene 30 (Tarea 11).

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_purchase_deducts():  # recuerdos=5 → purchase(&"forma_1") true; recuerdos 3; en purchased_skills
func test_reject_insufficient():  # recuerdos=1 → false; recuerdos sigue 1
func test_reject_missing_prereq():  # recuerdos=10 → purchase(&"forma_2") false
func test_reject_already_owned():  # comprar forma_1 dos veces → segunda false, sin descontar
func test_reject_missing_ability():  # marea_1 comprado, sin &"puddle" → marea_2 false
func test_mods_combine():  # forma_1 + voracidad_1 → max_hp_bonus 20, damage_mult 1.1, ink_gain_mult 1.25
func test_all_nine_nodes_load():  # load_all() tiene 9 nodos, coste total 27
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar y crear los `.tres`. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: commit** `feat: skill tree with 9 prototype nodes`

---

### Tarea 4: Jugador — movimiento

**Archivos:**
- Crear: `player/movement_config.gd`, `player/movement_config.tres`, `player/movement_math.gd`, `player/state_machine.gd`, `player/states/{player_state,idle,run,jump,fall,wall_slide,dash}.gd`, `player/player.gd`, `player/player.tscn`, `tests/scenes/test_room.tscn`
- Pruebas: `tests/test_movement_math.gd`, `tests/test_player_movement.gd`

**Interfaces:**
- Consume: `StatMods` (Tarea 3), `InkMeter.speed_mult()` (Tarea 1).
- Produce:
  - `class_name MovementConfig extends Resource`: `run_speed = 520.0`, `run_accel = 4200.0`, `run_decel = 5200.0`, `air_accel = 3200.0`, `jump_height = 220.0`, `time_to_apex = 0.36`, `fall_gravity_mult = 1.6`, `jump_cut_mult = 0.45` (al soltar salto con velocidad hacia arriba), `max_fall_speed = 1100.0`, `coyote_time = 0.10`, `jump_buffer = 0.12`, `dash_speed = 900.0`, `dash_time = 0.16`, `dash_cooldown = 0.35`, `wall_slide_speed = 180.0`, `wall_jump_velocity = Vector2(480, -620)`, `wall_jump_lock = 0.14`. Collider del jugador: cápsula de 40×96 px.
  - `class_name MovementMath` (estático): `static func jump_velocity(height: float, apex: float) -> float` (= `-2·h/t`), `static func gravity(height: float, apex: float) -> float` (= `2·h/t²`), `static func approach(v: float, target: float, rate: float, delta: float) -> float`.
  - `class_name PlayerStateMachine extends Node`: `func transition(state_name: StringName) -> void`, `current: PlayerState`. `class_name PlayerState extends Node`: `player: Player`, `enter()`, `exit()`, `physics_update(delta: float)`, `handle_input(event)`.
  - `class_name Player extends CharacterBody2D`: `config: MovementConfig`, `mods: StatMods`, `facing: int` (±1), `coyote_timer: float`, `jump_buffer_timer: float`, `func can_dash() -> bool`, `func refresh_mods() -> void` (recalcula desde `SkillTree`), señales `landed(impact_speed: float)`, `jumped()`, `dashed()`, `wall_jumped()`.

- [ ] **Paso 1: pruebas de fórmulas**
```gdscript
func test_jump_velocity():  assert_almost_eq(MovementMath.jump_velocity(220, 0.36), -1222.2, 0.5)
func test_gravity():        assert_almost_eq(MovementMath.gravity(220, 0.36), 3395.1, 0.5)
func test_approach_no_overshoot():  # approach(0, 100, 1000, 1.0) == 100
```
- [ ] **Paso 2: pruebas de simulación** (instancian `test_room.tscn` con suelo plano y una pared; usan `Input.action_press` + `await wait_physics_frames(n)`)
```gdscript
func test_reaches_run_speed():     # mantener move_right 30 frames → velocity.x ≈ 520 (±1)
func test_jump_apex_height():      # pulsar jump y mantener → altura máx. 220 ±8 px
func test_short_hop():             # soltar jump a los 3 frames → altura máx. < 120 px
func test_coyote_jump():           # salir del borde, pulsar jump a los 0.08 s → salta
func test_no_jump_after_coyote():  # pulsar a los 0.15 s → no salta
func test_jump_buffer():           # pulsar jump 0.1 s antes de aterrizar → salta al tocar suelo
func test_dash_distance():         # dash desde parado → recorre 144 ±10 px (900·0.16)
func test_dash_cooldown():         # segundo dash antes de 0.35 s → ignorado
func test_wall_slide_speed_cap():  # contra la pared cayendo → velocity.y ≤ 180
```
- [ ] **Paso 3:** ejecutar → FALLA. **Paso 4:** implementar estados y `Player`. Aplicar `fall_gravity_mult` cuando `velocity.y > 0` y `dash_distance_mult` a `dash_time`. **Paso 5:** ejecutar → PASA.
- [ ] **Paso 6: commit** `feat: player movement state machine with coyote, buffer, dash, wall jump`

---

### Tarea 5: Jugador — combate, curación, Desborde, muerte

**Archivos:**
- Crear: `player/states/{attack,heal,hurt,dead}.gd`, `player/player_combat.gd`, `autoload/hit_stop.gd`
- Modificar: `player/player.gd`, `player/player.tscn` (hitbox de ataque, hurtbox)
- Pruebas: `tests/test_player_combat.gd`, `tests/scenes/dummy_enemy.tscn` (hurtbox + Health con 1000 PV)

**Interfaces:**
- Consume: `Health`, `InkMeter`, `Hitbox/Hurtbox`, `EventBus`, `StatMods`, `GameState.last_tintero`.
- Produce:
  - `Player.health: Health`, `Player.ink: InkMeter`, `func respawn(at: Vector2) -> void` (resetea `health` e `ink`, i-frames 1 s).
  - Ataque: `base_damage = 10` × `ink.damage_dealt_mult()` × `mods.damage_mult`; duración 0.28 s, enfriamiento 0.32 s; hitbox lateral 110×70, arriba/abajo 80×110, escalada por `mods.attack_range_mult`. Hacia abajo solo en el aire; al acertar: `velocity.y = jump_velocity(150, 0.3)` (*pogo*) y recarga el dash si `mods.dash_refresh_on_hit`.
  - Al acertar: `ink.gain(ink_per_hit · mods.ink_gain_mult)`, `EventBus.hit_landed.emit(pos, strength)`, `HitStop.trigger(0.05)`.
  - Al recibir daño: retroceso, 1.0 s de invulnerabilidad, `HitStop.trigger(0.08)`.
  - Curación: mantener `heal` en el suelo durante `heal_time · mods.heal_time_mult`; al completar gasta `heal_cost` y cura `heal_amount`. Si te golpean, se cancela sin gastar.
  - `max_hp = 100 + mods.max_hp_bonus`.
  - `HitStop` (autoload): `func trigger(duration: float) -> void` (pone `Engine.time_scale = 0.05` durante `duration` en tiempo real).
  - Muerte: `EventBus.player_died` → tras 1.2 s, `respawn()` en el Tintero `GameState.last_tintero`.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_attack_damages_dummy():   # atacar al dummy → pierde 10 PV
func test_hit_gains_ink():          # 1 golpe → ink == 12
func test_pogo_bounces():           # atacar hacia abajo sobre el dummy en el aire → velocity.y < 0
func test_heal_full():              # ink=100, hp=50, mantener heal 0.8 s → hp 75, ink 67
func test_heal_interrupted():       # recibir golpe a mitad → hp sin curar, ink sin gastar
func test_invulnerable_after_hit(): # dos golpes en 0.5 s → solo cuenta uno
func test_respawn_clears_overflow():  # forzar OVERFLOW, morir, respawn → state NORMAL, instability 0, hp max
func test_respawn_clears_vulnerable():  # igual, desde VULNERABLE
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: commit** `feat: player combat, healing, overflow and respawn`

---

### Tarea 6: Forma charco

**Archivos:**
- Crear: `player/states/puddle.gd`, `world/grate.gd`, `world/grate.tscn`, `world/ability_shrine.gd`, `world/ability_shrine.tscn`
- Modificar: `player/player.tscn` (colisionador de charco: 72×20 px; `ShapeCast2D` del tamaño de pie para comprobar si cabe)
- Pruebas: `tests/test_puddle.gd`

**Interfaces:**
- Consume: `GameState.has_ability/unlock_ability`, `StatMods.puddle_contact_damage`.
- Produce:
  - Estado `puddle`: entrar con `puddle` (solo si `GameState.has_ability(&"puddle")`); velocidad 620 px/s en el suelo; ignora la capa 6 (`grates`); invulnerable los primeros 0.25 s; no puede atacar ni curarse; gravedad normal. Salir al soltar `puddle` **solo si** el `ShapeCast2D` de pie no colisiona; si no cabe, sigue en charco.
  - Si `mods.puddle_contact_damage > 0`, una hitbox de charco hace ese daño (una vez por enemigo y entrada).
  - `Grate`: `StaticBody2D` en la capa 6.
  - `AbilityShrine`: `ability_id: StringName`; al interactuar llama a `GameState.unlock_ability` y emite `EventBus.ability_unlocked`; si ya está desbloqueada no hace nada.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_cannot_puddle_without_ability():
func test_puddle_passes_grate():     # con habilidad, en charco, moverse a través de la rejilla → pasa al otro lado
func test_grate_blocks_normal():     # sin charco → no pasa
func test_cannot_unpuddle_under_low_ceiling():  # en túnel de 40 px de alto, soltar puddle → sigue en estado puddle
func test_unpuddle_when_space():     # salir del túnel y soltar → estado idle
func test_shrine_unlocks_once():
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: commit** `feat: puddle form ability with grates and ability shrine`

---

### Tarea 7: Cuerpo de tinta procedural (animación)

**Archivos:**
- Crear: `player/body/ink_body.gd`, `player/body/ink_body.gdshader`, `player/body/drip_chain.gd`, `player/body/pose_library.gd`
- Modificar: `player/player.tscn` (sustituir el rectángulo provisional por `InkBody`)
- Pruebas: `tests/test_ink_body.gd`

**Interfaces:**
- Consume: velocidad, estado, `facing` e `ink.instability` de `Player`.
- Produce:
  - `class_name InkBody extends Node2D`: cuerpo formado por `Polygon2D` (torso, cabeza, 2 brazos, 2 piernas, capa/cola) colgados de un `Skeleton2D`. `func set_pose_target(pose: StringName) -> void`, `func set_instability(v: float) -> void` (0–100). Las poses se mezclan con muelles críticamente amortiguados (`frequency = 8 Hz`, `damping = 1.0`), nunca por cortes.
  - `class_name PoseLibrary`: diccionario de poses (rotaciones de huesos y escala) para `idle, run_a, run_b, jump_up, apex, fall, land, wall, dash, attack_side_windup, attack_side_strike, attack_up, attack_down, heal, puddle, hurt, dead`. Correr alterna `run_a`/`run_b` en función de la distancia recorrida, no del tiempo.
  - Squash & stretch: escala Y = `1 + clamp(-vel.y/2400, -0.25, 0.25)`, con conservación de área en X; aterrizaje: aplastamiento de 0.2 que se recupera en 0.12 s.
  - Anticipación: el ataque entra por `attack_*_windup` (0.05 s) antes del golpe.
  - `DripChain`: 4 gotas colgantes con cadena verlet (8 iteraciones) unida a manos y capa; con más Inestabilidad, más largas y más gotas (hasta 8).
  - `ink_body.gdshader` (canvas_item): borde ondulante por ruido animado (`wobble_amount = 1.5 + instability·0.06` px), brillo especular húmedo en el borde superior, y en Desborde un *rim light* violeta→carmesí con valores HDR > 1 para que brille con el *glow*.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_shader_compiles():        # cargar el material y asignarlo sin errores
func test_all_poses_defined():      # cada estado del jugador tiene pose en PoseLibrary
func test_instability_maps_to_wobble():  # set_instability(100) → parámetro wobble_amount == 7.5
func test_pose_blend_is_continuous():    # cambiar de pose y avanzar 1 frame → la rotación del hueso cambia < 25% de la diferencia
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5:** **validación del autor:** jugar y valorar del 1 al 5 la fluidez de correr, saltar, dash y atacar. Ajustar las poses o el muelle hasta que todo sea ≥ 4.
- [ ] **Paso 6: commit** `feat: procedural ink body with spring-blended poses and ink shader`

---

### Tarea 8: Cámara, partículas, luz y *game feel*

**Archivos:**
- Crear: `vfx/game_camera.gd`, `vfx/drop_texture.gd`, `vfx/particles/{hit_splash,land_splash,dash_trail,drip,overflow_burst,ambient_ash,recuerdo_glow,puddle_enter}.tscn`, `vfx/splatter_decals.gd`, `vfx/vfx_spawner.gd`, `ui/fps_counter.gd`
- Pruebas: `tests/test_camera.gd`, `tests/test_vfx.gd`

**Interfaces:**
- Consume: `EventBus.hit_landed`, señales del jugador (`landed`, `dashed`, `jumped`), `InkMeter` (señales de Desborde).
- Produce:
  - `class_name GameCamera extends Camera2D`: seguimiento con amortiguación (`position_smoothing_speed = 7`), anticipación horizontal de 120 px en la dirección del movimiento, `func set_room_limits(rect: Rect2) -> void`, `func shake(strength: float, duration: float) -> void` (ruido, no aleatorio puro; decae al cuadrado). Si la sala es más pequeña que la vista en un eje, la cámara se centra en ese eje.
  - `DropTexture`: genera por código texturas suaves de gota (128×128, radial con borde blando) para todas las partículas.
  - `VfxSpawner` (hijo del mundo): escucha señales y crea las partículas `GPUParticles2D` one-shot. Las salpicaduras heredan la dirección del golpe y caen con gravedad.
  - `SplatterDecals`: hasta 64 manchas en el escenario que se desvanecen en 20 s.
  - `WorldEnvironment` con *glow* activado (bloom suave sobre valores HDR > 1).
  - `FpsCounter`: se activa con `debug_fps`.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_camera_clamped_ultrawide():  # viewport 3440×1440, sala 2400×1080 → la vista no sale de la sala; si es más estrecha, centrada
func test_camera_clamped_16_10():      # viewport 1920×1200
func test_shake_decays_to_zero():      # shake(10, 0.3); tras 0.35 s offset == Vector2.ZERO
func test_hit_spawns_splash():         # EventBus.hit_landed → aparece un hijo hit_splash
func test_all_particle_scenes_load():
func test_decal_cap():                 # 100 manchas → como máximo 64 nodos
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: validación del autor:** comprobar que las partículas "se ven geniales" en golpe, dash, aterrizaje y Desborde, y que el contador muestra ≥ 60 FPS. Ajustar.
- [ ] **Paso 6: commit** `feat: smooth camera, ink particles, glow and screen shake`

---

### Tarea 9: Enemigos (patrullero, volador, tirador)

**Archivos:**
- Crear: `enemies/enemy_base.gd`, `enemies/enemy_stats.gd`, `enemies/crawler/{crawler.gd,crawler.tscn,crawler_stats.tres}`, `enemies/flyer/…`, `enemies/spitter/{…,ink_projectile.gd,ink_projectile.tscn}`
- Pruebas: `tests/test_enemies.gd`

**Interfaces:**
- Consume: `Health`, `Hitbox/Hurtbox`, `EventBus`, `HitStop`, partículas de la Tarea 8.
- Produce:
  - `class_name EnemyStats extends Resource`: `max_hp`, `contact_damage`, `move_speed`, `recuerdo_drop_chance`, `aggro_range`.
  - `class_name EnemyBase extends CharacterBody2D`: `stats: EnemyStats`, `health: Health`, `spawn_position: Vector2`, `func reset_enemy() -> void` (vuelve a su posición con vida llena; lo usan los Tinteros), retroceso al recibir golpe, destello blanco 0.06 s, muerte con explosión de tinta y `EventBus.enemy_killed`. Cuerpo dibujado con `Polygon2D` + el shader de tinta de la Tarea 7 (silueta negra), animación procedural con muelles.
  - **Patrullero (crawler):** PV 30, contacto 20, velocidad 140; camina y se da la vuelta en paredes y bordes.
  - **Volador (flyer):** PV 20, contacto 20; flota con onda senoidal y, cuando el jugador está a menos de 420 px, se lanza en picado tras 0.4 s de aviso (se encoge y tiembla).
  - **Tirador (spitter):** PV 40, contacto 15; fijo, dispara un proyectil de tinta en arco cada 2.2 s si el jugador está a menos de 700 px, con 0.5 s de aviso (se hincha). Proyectil: daño 20, se destruye en el mundo con salpicadura.
  - Probabilidad de soltar 1 Recuerdo: 10 %.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_crawler_turns_at_ledge():
func test_crawler_dies_after_three_hits():  # 3 golpes de 10 → muerto
func test_flyer_telegraphs_before_dive():   # jugador cerca → no se mueve en picado antes de 0.4 s
func test_spitter_fires_on_interval():      # jugador a 500 px → 1 proyectil en 2.8 s
func test_spitter_ignores_far_player():     # jugador a 900 px → 0 proyectiles
func test_reset_restores_enemy():           # dañar, moverse, reset_enemy → posición y PV iniciales
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: commit** `feat: crawler, flyer and spitter enemies`

---

### Tarea 10: Jefe "El Escriba Hueco"

**Archivos:**
- Crear: `bosses/scribe/{scribe.gd,scribe.tscn,scribe_stats.tres,ink_wave.tscn}`, `world/boss_arena.gd`
- Pruebas: `tests/test_boss.gd`

**Interfaces:**
- Consume: `EnemyBase` (hereda), `EventBus.boss_defeated`, `GameCamera.set_room_limits/shake`.
- Produce:
  - Jefe original de la Zona 1: un escriba alto y encorvado, a medio borrar, con una pluma enorme. PV 600, 2 fases (la fase 2 empieza al 50 %).
  - **Ataques fase 1:** *Trazo* (embestida horizontal con la pluma, aviso de 0.6 s), *Borrón* (salta y cae sobre la posición del jugador, aviso: sombra en el suelo durante 0.7 s), *Gotas* (3 proyectiles en abanico).
  - **Fase 2:** se vuelve más rápido (×1.25) y añade *Ola de tinta* (ola por el suelo que hay que saltar). Transición: rugido, sacudida de cámara y explosión de partículas.
  - Sin repetir el mismo ataque más de 2 veces seguidas.
  - `BossArena`: cierra las puertas al entrar, muestra el nombre del jefe y su barra de vida, y al vencerlo emite `boss_defeated(&"scribe")`, suelta 8 Recuerdos y abre las puertas. Si ya fue derrotado (`GameState.bosses_defeated`), la arena queda vacía y abierta.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_phase_two_at_half_hp():
func test_no_attack_repeated_thrice():   # simular 50 elecciones → nunca 3 iguales seguidas
func test_defeat_emits_and_drops():      # matar → boss_defeated(&"scribe"), recuerdos +8
func test_defeated_boss_not_respawned(): # bosses_defeated contiene &"scribe" → arena abierta, sin jefe
func test_arena_locks_on_enter():
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: validación del autor:** el jefe es exigente pero justo y todos los ataques se pueden leer. Ajustar los tiempos de aviso.
- [ ] **Paso 6: commit** `feat: Hollow Scribe boss with two phases`

---

### Tarea 11: Mundo — salas, transiciones, Tinteros, Recuerdos y Zona 1

**Archivos:**
- Crear: `world/{room.gd,room_transition.gd,tintero.gd,tintero.tscn,recuerdo.gd,recuerdo.tscn,world.gd,world.tscn}`, `world/zone1/r01.tscn … r10.tscn`, `docs/zone1_map.md`
- Pruebas: `tests/test_world.gd`

**Interfaces:**
- Consume: todo lo anterior.
- Produce:
  - `class_name Room extends Node2D`: `room_id: StringName`, `bounds: Rect2` (para la cámara), `func get_entry(entry_id: StringName) -> Vector2`. Geometría con `TileMapLayer` de colisión invisible + formas de suelo dibujadas con `Polygon2D` (nada de tiles visibles de píxeles).
  - `RoomTransition` (Area2D): `target_room: StringName`, `target_entry: StringName`. Fundido a negro de 0.25 s; el jugador conserva su velocidad y estado (también en charco y en dash).
  - `World`: carga y descarga una sala cada vez, coloca al jugador, actualiza los límites de la cámara y guarda `GameState.last_room`.
  - `Tintero`: `tintero_id`; al interactuar → cura del todo, `GameState.last_tintero = id`, `SaveManager.save(0)`, reinicia los enemigos de todas las salas (`reset_enemy` / reaparición al recargar) y abre el árbol de habilidades (Tarea 12).
  - `Recuerdo` (pickup): `pickup_id` único; al recogerlo `add_recuerdos(value)` y se guarda en `collected_pickups` para que no reaparezca.
  - **Zona 1, "Las Afueras Borradas" (10 salas):** r01 despertar (tutorial de movimiento) → r02 primeros patrulleros → r03 **Tintero 1** + rejilla visible (bloqueada) → r04 saltos de pared + voladores → r05 tiradores y vertical → r06 **santuario de la forma charco** tras un reto de plataformas → r07 regreso por la rejilla de r03 (atajo) → r08 sala secreta solo accesible en charco → r09 **Tintero 2** antes del jefe → r10 **arena del Escriba Hueco**. Recuerdos: 22 en pickups (escondidos, con más valor en los más difíciles) + 8 del jefe = 30. Esquema en `docs/zone1_map.md`.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_all_rooms_load():                 # r01..r10 se instancian sin errores
func test_transitions_point_to_valid_entries():  # cada RoomTransition apunta a una sala y entrada que existen
func test_transition_preserves_puddle():    # cruzar en charco → sigue en charco
func test_tintero_saves_and_heals():
func test_pickup_not_respawned():           # recoger, recargar sala → no está
func test_zone_recuerdos_total_is_30():     # suma de pickups + jefe == 30
func test_puddle_gate_requires_ability():   # r03 → r07 solo transitable con charco
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar y construir las salas. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: validación del autor:** recorrer la zona entera; comprobar que no te quedas atrapado y que el atajo y la sala secreta se encuentran.
- [ ] **Paso 6: commit** `feat: room system, tinteros, recuerdos and zone 1 layout`

---

### Tarea 12: Interfaz — HUD, pausa, árbol de habilidades, menú principal

**Archivos:**
- Crear: `ui/{hud.tscn,hud.gd,pause_menu.tscn,pause_menu.gd,skill_tree_ui.tscn,skill_tree_ui.gd,main_menu.tscn,main_menu.gd}`, `locale/es.csv`
- Pruebas: `tests/test_ui.gd`

**Interfaces:**
- Consume: `Player.health/ink`, `GameState`, `SkillTree`, `SaveManager`.
- Produce:
  - **HUD:** vida como una "gota" que se vacía (shader con nivel animado suave, no barras de píxeles), medidor de tinta, anillo de Inestabilidad que late con más intensidad cuanto más alta es, y contador de Recuerdos que sube con animación.
  - **Pausa:** Continuar / Volver al menú; detiene el árbol de escena (`get_tree().paused`).
  - **Árbol de habilidades:** 3 columnas (Forma, Marea, Voracidad), nodos con estado bloqueado / disponible / comprado, descripción al seleccionar y compra confirmada con un botón. Navegable con mando y teclado. Llama a `SkillTree.purchase` y después a `Player.refresh_mods()`.
  - **Menú principal:** Continuar (si `has_save(0)`) / Nueva partida / Salir.
  - Todos los textos mediante `tr()` desde `locale/es.csv`.

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_skill_ui_reflects_states():   # comprado / disponible / bloqueado según GameState
func test_purchase_via_ui_updates_player():  # comprar forma_1 → player.health.max_hp == 120
func test_pause_stops_tree():
func test_continue_hidden_without_save():
func test_all_ui_texts_translated():    # ninguna etiqueta visible muestra una clave sin traducir
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: commit** `feat: HUD, pause menu, skill tree UI and main menu`

---

### Tarea 13: Arte de fondos (Higgsfield) e integración *parallax*

**Archivos:**
- Crear: `docs/art/prompts.md`, `art/parallax_background.gd`, `tools/strip_background.py`
- Modificar: `world/zone1/r01.tscn`, `r06.tscn`, `r10.tscn` (fondos definitivos); el resto, con fondo provisional degradado + niebla.
- Pruebas: `tests/test_parallax.gd`

**Interfaces:**
- Consume: `GameCamera`, `Room.bounds`.
- Produce:
  - `docs/art/prompts.md`: guía de estilo (paleta de la spec §5.2, luz difusa, niebla, pintura digital con pinceladas visibles, "no pixel art, no characters", 16:9 y 4K) + prompts concretos por sala y capa (lejana, media, cercana) para r01, r06 y r10, con instrucciones para el autor: dónde generarlos y cómo nombrar los archivos (`art/backgrounds/zone1/<sala>_<capa>.png`).
  - **Escenario en profundidad (spec §5.1b):** `class_name DepthLayer extends Node2D` con `@export var depth: float` y `@export var fog_color: Color`; `static func parallax_factor(depth: float) -> float` (= `1000 / (1000 + depth)`); cada frame se desplaza respecto a la cámara para que `pantalla = posición − cámara·factor`; niebla `fog_amount = clamp(depth / 3000, 0, 0.85)` mezclada hacia `fog_color`; con `depth < 0` se oscurece hacia silueta (`modulate` ×0.15) y se desenfoca con shader. Las imágenes de Higgsfield son `DepthLayer` (lejana ≈ 4000, media ≈ 1500, cercana ≈ 400) y además cada sala tiene elementos sueltos (columnas, ramas, cadenas, ruinas) a profundidades variadas, dibujados con `Polygon2D` mientras no haya arte. La Tarea 11 construye las salas con estos elementos.
  - `tools/strip_background.py`: quita el fondo de una capa (PNG con transparencia) usando `rembg`.
  - Si falta una imagen, se muestra un sustituto rosa visible y se registra un aviso (spec §8.5).

- [ ] **Paso 1: pruebas que fallan**
```gdscript
func test_parallax_factors():   # depth 0 → 1.0; depth 1000 → 0.5; depth -200 → 1.25
func test_fog_increases_with_depth():
func test_foreground_darkened(): # depth -200 → modulate más oscuro que depth 0
func test_missing_layer_uses_placeholder():  # ruta inexistente → textura sustituta, sin errores
```
- [ ] **Paso 2:** ejecutar → FALLA. **Paso 3:** implementar y escribir `prompts.md`. **Paso 4:** ejecutar → PASA.
- [ ] **Paso 5: autor:** generar las 9 imágenes en Higgsfield; Claude las revisa (coherencia de estilo y paleta), quita fondos si hace falta y las integra.
- [ ] **Paso 6: commit** `feat: parallax backgrounds and Higgsfield prompt guide`

---

### Tarea 14: Exportación y validación final

**Archivos:**
- Crear: `export_presets.cfg` (Windows, Linux, macOS)
- Modificar: `README.md`

- [ ] **Paso 1:** `./tools/test.sh` → todo PASA.
- [ ] **Paso 2:** `godot --headless --path . --quit` sin errores ni avisos de scripts.
- [ ] **Paso 3:** exportar la build de Windows (o la plataforma del autor) a `export/` con las plantillas de exportación de la misma versión de Godot.
- [ ] **Paso 4: validación del autor (criterios de la spec §2):** partida completa de principio a fin sin fallos graves; el movimiento se siente ágil; ≥ 60 FPS estables; ganas de seguir explorando. Anotar los problemas como tareas nuevas.
- [ ] **Paso 5: commit** `chore: export presets and prototype release notes`

---

## Fuera de este plan (Hito 2, Beta)

Zonas 2 y 3, núcleo central, habilidades llave hilo de tinta y salto salpicado, árbol completo, mapa, PNJ, tienda, música y sonido definitivos, mancha de muerte, menú de opciones y varias ranuras de guardado. Tendrán su propio plan cuando el Prototipo esté validado.
