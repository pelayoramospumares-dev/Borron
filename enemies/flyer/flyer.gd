extends EnemyBase
## Volador: polilla de tinta. Flota y, si el jugador se acerca, avisa
## encogiéndose y temblando 0.4 s y luego se lanza en picado.

const TELEGRAPH := 0.4
const DIVE_SPEED := 900.0
const DIVE_TIME := 0.8
const RETURN_SPEED := 260.0
const COOLDOWN := 1.5

var state: StringName = &"hover"
var _t: float = 0.0
var _state_t: float = 0.0
var _dive_dir: Vector2 = Vector2.DOWN
var _wing_l: Node2D
var _wing_r: Node2D
var _tail: Node2D


func _ready() -> void:
	uses_gravity = false
	super()


func _ai(delta: float) -> void:
	_t += delta
	_state_t += delta
	match state:
		&"hover":
			var home := spawn_position + Vector2(sin(_t * 0.9) * 40.0, sin(_t * 1.7) * 18.0)
			velocity = (home - global_position) * 3.0
			var p := player_in_range(stats.aggro_range)
			if p:
				_set_state(&"telegraph")
		&"telegraph":
			velocity = velocity.move_toward(Vector2.ZERO, 2000.0 * delta)
			if _state_t >= TELEGRAPH:
				var p := find_player()
				_dive_dir = (p.global_position - global_position).normalized() if p else Vector2.DOWN
				_set_state(&"dive")
		&"dive":
			velocity = _dive_dir * DIVE_SPEED
			if _state_t >= DIVE_TIME or get_slide_collision_count() > 0:
				_set_state(&"recover")
		&"recover":
			var to_home := spawn_position - global_position
			velocity = to_home.normalized() * RETURN_SPEED if to_home.length() > 8.0 else Vector2.ZERO
			if _state_t >= COOLDOWN and to_home.length() < 40.0:
				_set_state(&"hover")
	_animate()


func _set_state(s: StringName) -> void:
	state = s
	_state_t = 0.0


func _on_reset() -> void:
	_set_state(&"hover")


func _build_body(g: EnemyBody) -> void:
	_wing_l = Node2D.new()
	_wing_r = Node2D.new()
	g.add_child(_wing_l)
	g.add_child(_wing_r)
	var wing := [Vector2(0, -2), Vector2(-14, -26), Vector2(-40, -30), Vector2(-46, -12), Vector2(-30, 4),
			Vector2(-38, 18), Vector2(-16, 14), Vector2(0, 6)]
	EnemyBody.poly(_wing_l, wing)
	var mirrored: Array = []
	for v: Vector2 in wing:
		mirrored.append(Vector2(-v.x, v.y))
	EnemyBody.poly(_wing_r, mirrored)
	EnemyBody.poly(g, EnemyBody.ellipse(Vector2(0, 0), Vector2(9, 16), 14))
	_tail = Node2D.new()
	_tail.position = Vector2(0, 14)
	g.add_child(_tail)
	EnemyBody.poly(_tail, [Vector2(-4, 0), Vector2(4, 0), Vector2(1, 26), Vector2(-1, 26)])
	EnemyBody.poly(g, EnemyBody.ellipse(Vector2(-4, -6), Vector2(2.2, 3.2), 10), Color(1.9, 1.9, 2.1))
	EnemyBody.poly(g, EnemyBody.ellipse(Vector2(4, -6), Vector2(2.2, 3.2), 10), Color(1.9, 1.9, 2.1))


func _animate() -> void:
	var flap_speed := 30.0 if state == &"telegraph" else 16.0
	var flap := sin(_t * flap_speed) * 0.55
	_wing_l.rotation = flap
	_wing_r.rotation = -flap
	_wing_l.scale.y = 1.0 - absf(flap) * 0.3
	_wing_r.scale.y = _wing_l.scale.y
	_tail.rotation = -velocity.x * 0.0012 + sin(_t * 4.0) * 0.2
	if state == &"telegraph":
		body.scale = Vector2.ONE * (1.0 - 0.25 * minf(_state_t / TELEGRAPH, 1.0))
		body.position = Vector2(randf_range(-2, 2), randf_range(-2, 2))
	else:
		body.scale = body.scale.lerp(Vector2.ONE, 0.2)
		body.position = Vector2.ZERO
	if state == &"dive":
		body.rotation = _dive_dir.angle() - PI * 0.5
	else:
		body.rotation = lerp_angle(body.rotation, 0.0, 0.15)
