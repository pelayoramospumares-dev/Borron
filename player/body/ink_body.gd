class_name InkBody
extends Node2D
## Cuerpo de tinta del protagonista: silueta construida por código, animada con
## muelles amortiguados (nunca por fotogramas sueltos) y con shader de tinta.
## Si su padre es un Player, lo lee cada frame para elegir pose.

const SHADER := preload("res://player/body/ink_body.gdshader")
const FEET_Y := 48.0
## Muelles de pose: frecuencia (Hz) y amortiguación (1 = crítica).
const POSE_FREQ := 8.0
const POSE_DAMP := 1.0
const CLOAK_FREQ := 3.5
const CLOAK_DAMP := 0.35
const MAX_SUBSTEP := 1.0 / 240.0
const RUN_STRIDE := 120.0
const BODY_SCALE := 0.92
const EYE_COLOR := Color(1.7, 1.75, 2.0)

var facing: int = 1
var velocity: Vector2 = Vector2.ZERO
var instability: float = 0.0

var _pos: Dictionary = {}
var _vel: Dictionary = {}
var _target: Dictionary = {}
var _target_name: StringName = &"idle"
var _run_phase: float = 0.0
var _land_squash: float = 0.0
var _cloak: float = 0.0
var _cloak_v: float = 0.0
var _puddle: float = 0.0
var _puddle_v: float = 0.0
var _puddle_target: float = 0.0
var _overflow: float = 0.0
var _overflow_target: float = 0.0
var _flash: float = 0.0
var _jitter_t: float = 0.0

var _group: CanvasGroup
var _material: ShaderMaterial
var _root: Node2D
var _hip: Node2D
var _chest: Node2D
var _head: Node2D
var _arm_f: Node2D
var _arm_b: Node2D
var _leg_f: Node2D
var _leg_b: Node2D
var _cloak_node: Node2D
var _blade: Polygon2D
var _eyes: Node2D
var _drips: Array[DripChain] = []
var _drip_anchors: Array[Node2D] = []


func _ready() -> void:
	_build()
	snap_to_pose(&"idle")
	var p := get_parent() as Player
	if p:
		if not p.is_node_ready():
			await p.ready
		p.landed.connect(on_landed)
		p.hurt.connect(func(_a: float) -> void: _flash = 1.0)
		p.ink.overflow_started.connect(func() -> void: _overflow_target = 1.0)
		p.ink.overflow_ended.connect(func() -> void: _overflow_target = 0.0)


func _process(delta: float) -> void:
	var p := get_parent() as Player
	if p and p.is_node_ready():
		_sync_from_player(p)
	advance(delta)


# --- API -------------------------------------------------------------------

func set_pose_target(pose: StringName) -> void:
	if not PoseLibrary.POSES.has(pose):
		push_warning("InkBody: pose desconocida %s" % pose)
		return
	_target_name = pose
	for ch in PoseLibrary.CHANNELS:
		_target[ch] = _to_internal(ch, PoseLibrary.POSES[pose][ch])
	_puddle_target = 1.0 if pose == &"puddle" else 0.0


func snap_to_pose(pose: StringName) -> void:
	set_pose_target(pose)
	for ch in PoseLibrary.CHANNELS:
		_pos[ch] = _target[ch]
		_vel[ch] = 0.0
	_apply()


func set_instability(v: float) -> void:
	instability = clampf(v, 0.0, 100.0)
	if _material:
		_material.set_shader_parameter(&"wobble_amount", wobble_amount())
	var segs := drip_segments()
	for d in _drips:
		d.segments = segs


func wobble_amount() -> float:
	return 1.5 + instability * 0.06


func drip_segments() -> int:
	return 2 + int(instability / 25.0)


func channel(ch: StringName) -> float:
	return _pos.get(ch, 0.0)


func on_landed(impact_speed: float) -> void:
	_land_squash = clampf(impact_speed / 1100.0, 0.05, 1.0) * 0.2


## Avanza la animación. Subpasos fijos para que sea estable con cualquier FPS.
func advance(delta: float) -> void:
	var remaining := delta
	while remaining > 0.0:
		var dt := minf(remaining, MAX_SUBSTEP)
		_step(dt)
		remaining -= dt
	_apply()


# --- Interno -----------------------------------------------------------------

func _sync_from_player(p: Player) -> void:
	facing = p.facing
	velocity = p.velocity
	set_instability(p.ink.instability)
	var state := p.sm.current_name()
	var attack_dir: StringName = &"side"
	var attack_t := 0.0
	if state == &"attack":
		var atk: Node = p.sm.states[&"attack"]
		attack_dir = atk.direction
		attack_t = atk.elapsed()
	var pose := PoseLibrary.pose_name_for(state, velocity.y, attack_dir, attack_t)
	if pose != _target_name:
		set_pose_target(pose)
	_blade.visible = state == &"attack" and attack_t >= PoseLibrary.ATTACK_WINDUP * 0.5 and attack_t < 0.2


func _step(dt: float) -> void:
	var w := TAU * POSE_FREQ
	var running := _target_name == &"run_a"
	if running:
		_run_phase += absf(velocity.x) * dt / RUN_STRIDE * TAU
	for ch in PoseLibrary.CHANNELS:
		var target: float = _target[ch]
		if running:
			var a := _to_internal(ch, PoseLibrary.POSES[&"run_a"][ch])
			var b := _to_internal(ch, PoseLibrary.POSES[&"run_b"][ch])
			target = lerpf(a, b, 0.5 + 0.5 * sin(_run_phase))
		var x: float = _pos[ch]
		var v: float = _vel[ch]
		v += (w * w * (target - x) - 2.0 * POSE_DAMP * w * v) * dt
		x += v * dt
		_pos[ch] = x
		_vel[ch] = v
	# Capa: movimiento secundario, más elástico.
	var cw := TAU * CLOAK_FREQ
	var cloak_target := deg_to_rad(8.0 + clampf(absf(velocity.x) * 0.06, 0.0, 55.0)
			+ clampf(velocity.y * 0.03, -20.0, 50.0))
	_cloak_v += (cw * cw * (cloak_target - _cloak) - 2.0 * CLOAK_DAMP * cw * _cloak_v) * dt
	_cloak += _cloak_v * dt
	# Charco: el cuerpo se derrite y vuelve a levantarse.
	var pw := TAU * 6.0
	_puddle_v += (pw * pw * (_puddle_target - _puddle) - 2.0 * 0.8 * pw * _puddle_v) * dt
	_puddle += _puddle_v * dt
	_land_squash = move_toward(_land_squash, 0.0, dt / 0.12 * 0.2)
	_overflow = move_toward(_overflow, _overflow_target, dt * 3.0)
	_flash = move_toward(_flash, 0.0, dt / 0.08)
	_jitter_t += dt


func _apply() -> void:
	if _root == null:
		return
	var stretch := clampf(-velocity.y / 2400.0, -0.25, 0.25) - _land_squash
	var sy := 1.0 + stretch
	var sx := 1.0 / maxf(sy, 0.1)
	var p := clampf(_puddle, -0.2, 1.2)
	sx = lerpf(sx, 1.8, p)
	sy = lerpf(sy, 0.16, p)
	_root.scale = Vector2(sx * facing, sy) * BODY_SCALE
	_root.position = Vector2(0, FEET_Y)
	_hip.position = Vector2(0, -26.0 + _pos[&"root_y"])
	var jitter := sin(_jitter_t * 47.0) * deg_to_rad(instability * 0.03)
	_chest.rotation = _pos[&"chest"] + jitter
	_head.rotation = _pos[&"head"] - jitter
	_arm_f.rotation = _pos[&"arm_f"]
	_arm_b.rotation = _pos[&"arm_b"]
	_leg_f.rotation = _pos[&"leg_f"]
	_leg_b.rotation = _pos[&"leg_b"]
	_leg_f.position.y = -_pos[&"root_y"]
	_leg_b.position.y = -_pos[&"root_y"]
	_cloak_node.rotation = _cloak
	if _material:
		_material.set_shader_parameter(&"overflow", _overflow)
		_material.set_shader_parameter(&"flash", _flash)


func _to_internal(ch: StringName, value: float) -> float:
	return value if ch == &"root_y" else deg_to_rad(value)


func _build() -> void:
	_group = CanvasGroup.new()
	_group.fit_margin = 16.0
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_group.material = _material
	add_child(_group)

	_root = _node(_group, Vector2(0, FEET_Y))
	_hip = _node(_root, Vector2(0, -26))
	# Piernas (detrás, luego delante).
	_leg_b = _node(_hip, Vector2(-5, 0))
	_poly(_leg_b, [Vector2(-4, 0), Vector2(4, 0), Vector2(3, 21), Vector2(8, 26), Vector2(-3, 26), Vector2(-3, 21)])
	# Capa por detrás del torso.
	_chest = _node(_hip, Vector2(0, -22))
	_cloak_node = _node(_chest, Vector2(-5, -2))
	_poly(_cloak_node, [Vector2(-2, -4), Vector2(8, -2), Vector2(9, 18), Vector2(4, 36), Vector2(1, 28),
			Vector2(-4, 42), Vector2(-7, 30), Vector2(-13, 38), Vector2(-12, 18)])
	_arm_b = _node(_chest, Vector2(-6, -2))
	_poly(_arm_b, _limb(22.0, 5.0))
	_leg_f = _node(_hip, Vector2(5, 0))
	_poly(_leg_f, [Vector2(-4, 0), Vector2(4, 0), Vector2(3, 21), Vector2(8, 26), Vector2(-3, 26), Vector2(-3, 21)])
	# Torso: gota alargada.
	_poly(_hip, [Vector2(-9, 5), Vector2(9, 5), Vector2(11, -10), Vector2(8, -24), Vector2(0, -30),
			Vector2(-8, -24), Vector2(-11, -10)])
	# Cabeza: gota de tinta con la punta inclinada hacia atrás.
	_head = _node(_chest, Vector2(0, -4))
	_poly(_head, _drop_shape())
	_eyes = _node(_head, Vector2.ZERO)
	_eye(_eyes, Vector2(-2, -20))
	_eye(_eyes, Vector2(7, -20))
	# Brazo delantero con hoja de tinta.
	_arm_f = _node(_chest, Vector2(6, -2))
	_poly(_arm_f, _limb(22.0, 5.4))
	_blade = _poly(_arm_f, [Vector2(-3, 18), Vector2(3, 18), Vector2(5, 46), Vector2(1, 78), Vector2(-4, 44)])
	_blade.visible = false

	# Gotas colgantes: punta de la capa y manos.
	for anchor_info: Array in [[_cloak_node, Vector2(-4, 40)], [_cloak_node, Vector2(4, 34)],
			[_arm_f, Vector2(0, 22)], [_arm_b, Vector2(0, 22)]]:
		var a := _node(anchor_info[0], anchor_info[1])
		_drip_anchors.append(a)
		var d := DripChain.new()
		d.anchor = a
		d.segments = drip_segments()
		add_child(d)
		_drips.append(d)


func _node(parent: Node, pos: Vector2) -> Node2D:
	var n := Node2D.new()
	n.position = pos
	parent.add_child(n)
	return n


func _poly(parent: Node, points: Array) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array(points)
	poly.color = Color(0, 0, 0)
	poly.antialiased = true
	parent.add_child(poly)
	return poly


func _eye(parent: Node, pos: Vector2) -> void:
	var pts: Array = []
	for i in 12:
		var a := TAU * i / 12.0
		pts.append(pos + Vector2(cos(a) * 2.6, sin(a) * 4.2))
	var e := _poly(parent, pts)
	e.color = EYE_COLOR


func _limb(length: float, width: float) -> Array:
	return [Vector2(-width * 0.5, -2), Vector2(width * 0.5, -2), Vector2(width * 0.4, length * 0.7),
			Vector2(0.5, length + 3), Vector2(-width * 0.45, length * 0.7)]


func _drop_shape() -> Array:
	# Arco de círculo (radio 15, centro (2,-18)) desde arriba-derecha, pasando por
	# abajo, hasta arriba-izquierda; se cierra con una punta inclinada hacia atrás.
	var c := Vector2(2, -18)
	var pts: Array = []
	var from := -0.9
	var to := PI + 0.6
	for i in 21:
		var a := lerpf(from, to, i / 20.0)
		pts.append(c + Vector2(cos(a), sin(a)) * 15.0)
	pts.append(Vector2(-10, -50))
	return pts
