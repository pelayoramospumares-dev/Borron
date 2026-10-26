class_name Scribe
extends EnemyBase
## Jefe de la Zona 1: El Escriba Hueco. Un escriba alto y encorvado, a medio
## borrar, con una pluma enorme. Dos fases; la segunda empieza al 50 % de vida.

signal phase_changed(phase: int)
signal roared()

const ATTACKS_P1: Array[StringName] = [&"trazo", &"borron", &"gotas"]
const ATTACKS_P2: Array[StringName] = [&"trazo", &"borron", &"gotas", &"ola"]
const PHASE2_SPEED := 1.25
const ROAR_TIME := 1.0
const FEET := 100.0

const TRAZO_TELEGRAPH := 0.6
const TRAZO_SPEED := 1100.0
const TRAZO_MAX := 1.2
const BORRON_CROUCH := 0.25
const BORRON_TELEGRAPH := 0.7
const BORRON_JUMP := -1500.0
const BORRON_SLAM := 2400.0
const GOTAS_TELEGRAPH := 0.45
const OLA_TELEGRAPH := 0.5
const RECOVER := 0.55
const IDLE_P1 := 0.7
const IDLE_P2 := 0.45

var phase: int = 1
var state: StringName = &"idle"
var facing: float = -1.0
var _history: Array[StringName] = []
var _t: float = 0.0
var _anim_t: float = 0.0
var _target_x: float = 0.0
var _slamming: bool = false

var _robe: Node2D
var _head: Node2D
var _arm: Node2D
var _quill_tip: Polygon2D
var _shadow: Polygon2D


func _ready() -> void:
	super()
	health.damaged.connect(func(_a: float) -> void:
		if phase == 1 and health.hp <= health.max_hp * 0.5 and not health.is_dead():
			_enter_phase_two())


func speed() -> float:
	return PHASE2_SPEED if phase == 2 else 1.0


## Elige el siguiente ataque sin repetir el mismo más de 2 veces seguidas.
func pick_next_attack() -> StringName:
	var pool := (ATTACKS_P2 if phase == 2 else ATTACKS_P1).duplicate()
	if _history.size() >= 2 and _history[-1] == _history[-2]:
		pool.erase(_history[-1])
	var choice: StringName = pool[randi() % pool.size()]
	_history.append(choice)
	if _history.size() > 4:
		_history.pop_front()
	return choice


func _enter_phase_two() -> void:
	phase = 2
	_set_state(&"roar")
	hurtbox.invulnerable = true
	velocity = Vector2.ZERO
	phase_changed.emit(2)
	roared.emit()
	for i in 4:
		EventBus.hit_landed.emit(global_position + Vector2(randf_range(-60, 60), randf_range(-150, 0)), 1.2)


func _set_state(s: StringName) -> void:
	state = s
	_t = 0.0
	_shadow.visible = false
	_slamming = false


func _on_reset() -> void:
	phase = 1
	_history.clear()
	_set_state(&"idle")


func _ai(delta: float) -> void:
	_t += delta * speed()
	_anim_t += delta
	var p := find_player()
	match state:
		&"idle":
			if p:
				facing = signf(p.global_position.x - global_position.x)
				if facing == 0.0:
					facing = 1.0
				velocity.x = move_toward(velocity.x, facing * 90.0, 600.0 * delta)
			if _t >= (IDLE_P2 if phase == 2 else IDLE_P1):
				velocity.x = 0.0
				_set_state(pick_next_attack())
		&"roar":
			velocity.x = 0.0
			if _t >= ROAR_TIME:
				hurtbox.invulnerable = false
				_set_state(&"idle")
		&"trazo":
			if _t < TRAZO_TELEGRAPH:
				velocity.x = 0.0
			elif _t < TRAZO_TELEGRAPH + TRAZO_MAX and not (is_on_wall() and _t > TRAZO_TELEGRAPH + 0.05):
				velocity.x = facing * TRAZO_SPEED * speed()
			else:
				velocity.x = 0.0
				EventBus.hit_landed.emit(global_position + Vector2(facing * 50, 0), 0.8)
				_set_state(&"recover")
		&"borron":
			_ai_borron(p, delta)
		&"gotas":
			velocity.x = 0.0
			if _t >= GOTAS_TELEGRAPH:
				if p:
					for off: float in [-220.0, 0.0, 220.0]:
						_shoot(p.global_position + Vector2(off, 0))
				_set_state(&"recover")
		&"ola":
			velocity.x = 0.0
			if _t >= OLA_TELEGRAPH:
				_spawn_wave()
				_set_state(&"recover")
		&"recover":
			velocity.x = move_toward(velocity.x, 0.0, 3000.0 * delta)
			if _t >= RECOVER:
				_set_state(&"idle")
	_animate()


func _ai_borron(p: Node2D, _delta: float) -> void:
	if _t < BORRON_CROUCH:
		velocity.x = 0.0
		if p:
			_target_x = p.global_position.x
		_place_shadow()
		return
	if not _slamming and is_on_floor() and velocity.y >= 0.0 and _t < BORRON_CROUCH + 0.05:
		velocity.y = BORRON_JUMP
	if not _slamming:
		velocity.x = clampf((_target_x - global_position.x) * 4.0, -900.0, 900.0)
		if _t >= BORRON_CROUCH + BORRON_TELEGRAPH:
			_slamming = true
			velocity = Vector2(0, BORRON_SLAM)
		return
	if is_on_floor():
		EventBus.hit_landed.emit(global_position + Vector2(0, FEET), 1.5)
		EventBus.hit_landed.emit(global_position + Vector2(-60, FEET), 1.0)
		EventBus.hit_landed.emit(global_position + Vector2(60, FEET), 1.0)
		_set_state(&"recover")


func _place_shadow() -> void:
	_shadow.visible = true
	_shadow.global_position = Vector2(_target_x, global_position.y + FEET - 2)


func _shoot(target: Vector2) -> void:
	var proj := InkProjectile.new()
	proj.source = self
	var from := _quill_tip.global_position
	proj.velocity = InkProjectile.launch_velocity(from, target)
	get_parent().add_child(proj)
	proj.global_position = from


func _spawn_wave() -> void:
	var wave := InkWave.new()
	wave.direction = facing
	wave.source = self
	get_parent().add_child(wave)
	wave.global_position = global_position + Vector2(facing * 70, FEET - 30)
	EventBus.hit_landed.emit(wave.global_position, 1.0)


# --- Cuerpo y animación ----------------------------------------------------------

func _build_body(g: EnemyBody) -> void:
	g.set_wobble(2.6)
	_robe = Node2D.new()
	g.add_child(_robe)
	# Túnica larga con el borde inferior deshilachado.
	EnemyBody.poly(_robe, [Vector2(-30, -70), Vector2(26, -74), Vector2(44, 10), Vector2(58, 96),
			Vector2(40, 84), Vector2(30, 100), Vector2(12, 88), Vector2(-4, 100), Vector2(-20, 86),
			Vector2(-36, 100), Vector2(-50, 90), Vector2(-44, 20)])
	# Joroba.
	EnemyBody.poly(_robe, EnemyBody.ellipse(Vector2(-14, -66), Vector2(34, 26), 16))
	_head = Node2D.new()
	_head.position = Vector2(18, -86)
	_robe.add_child(_head)
	# Cuello largo y cabeza a medio borrar (con mordiscos).
	EnemyBody.poly(_head, [Vector2(-6, 6), Vector2(4, 4), Vector2(14, -22), Vector2(6, -24)])
	EnemyBody.poly(_head, [Vector2(0, -20), Vector2(30, -26), Vector2(42, -18), Vector2(36, -6),
			Vector2(30, -12), Vector2(24, -2), Vector2(16, -10), Vector2(6, -4)])
	EnemyBody.poly(_head, EnemyBody.ellipse(Vector2(28, -17), Vector2(3.5, 2.5), 10), Color(2.2, 1.9, 1.2))
	_arm = Node2D.new()
	_arm.position = Vector2(20, -50)
	_robe.add_child(_arm)
	EnemyBody.poly(_arm, [Vector2(-5, 0), Vector2(5, 0), Vector2(4, 60), Vector2(-4, 60)])
	# Pluma: mástil y barbas.
	EnemyBody.poly(_arm, [Vector2(-2, 50), Vector2(2, 50), Vector2(1, 170), Vector2(-1, 170)])
	EnemyBody.poly(_arm, [Vector2(0, 70), Vector2(18, 90), Vector2(22, 130), Vector2(8, 160), Vector2(0, 150)])
	EnemyBody.poly(_arm, [Vector2(0, 74), Vector2(-14, 100), Vector2(-14, 136), Vector2(0, 150)])
	_quill_tip = EnemyBody.poly(_arm, [Vector2(-3, 170), Vector2(3, 170), Vector2(0, 186)], Color(1.6, 1.6, 1.9))
	_shadow = Polygon2D.new()
	_shadow.polygon = PackedVector2Array(EnemyBody.ellipse(Vector2.ZERO, Vector2(70, 10), 18))
	_shadow.color = Color(0.02, 0.02, 0.03, 0.55)
	_shadow.top_level = true
	_shadow.visible = false
	add_child(_shadow)


func _animate() -> void:
	body.scale.x = facing
	var sway := sin(_anim_t * 2.0)
	_robe.rotation = sway * 0.02
	_head.rotation = sin(_anim_t * 1.3) * 0.08
	var arm_target := -0.9 + sway * 0.06
	var squash := 1.0
	match state:
		&"trazo":
			if _t < TRAZO_TELEGRAPH:
				arm_target = -2.4
				body.position.x = randf_range(-2, 2)
			else:
				arm_target = -1.4
				_robe.rotation = 0.25
		&"borron":
			arm_target = -2.8
			if _t < BORRON_CROUCH:
				squash = 0.85
		&"gotas":
			arm_target = lerpf(-2.6, -0.6, clampf(_t / GOTAS_TELEGRAPH, 0.0, 1.0))
		&"ola":
			arm_target = lerpf(-2.8, 0.8, clampf(_t / OLA_TELEGRAPH, 0.0, 1.0))
		&"roar":
			_head.rotation = -0.5
			arm_target = -2.2
			body.position = Vector2(randf_range(-4, 4), randf_range(-3, 3))
		_:
			body.position = Vector2.ZERO
	_arm.rotation = lerp_angle(_arm.rotation, arm_target, 0.25)
	body.scale.y = lerpf(body.scale.y, squash, 0.3)
	_shadow.modulate.a = 0.5 + 0.5 * sin(_anim_t * 18.0) if _shadow.visible else 1.0
