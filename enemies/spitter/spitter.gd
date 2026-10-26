extends EnemyBase
## Tirador: tintero vivo, inmóvil. Si el jugador está cerca se hincha 0.5 s
## (aviso) y escupe un proyectil de tinta en arco cada 2.2 s.

const INTERVAL := 2.2
const TELEGRAPH := 0.5

var shots_fired: int = 0
var _timer: float = 0.0
var _t: float = 0.0
var _bulb: Node2D
var _mouth: Node2D


func _ai(delta: float) -> void:
	_t += delta
	velocity.x = move_toward(velocity.x, 0.0, 2000.0 * delta)
	var p := player_in_range(stats.aggro_range)
	if p == null:
		_timer = 0.0
	else:
		_timer += delta
		if _timer >= INTERVAL:
			_timer -= INTERVAL
			_fire(p)
	_animate(p)


func _fire(target: Node2D) -> void:
	shots_fired += 1
	var proj := InkProjectile.new()
	proj.source = self
	var from := global_position + Vector2(0, -50)
	proj.velocity = InkProjectile.launch_velocity(from, target.global_position)
	get_parent().add_child(proj)
	proj.global_position = from
	EventBus.hit_landed.emit(from, 0.3)


func _on_reset() -> void:
	_timer = 0.0


func _build_body(g: EnemyBody) -> void:
	_bulb = Node2D.new()
	g.add_child(_bulb)
	# Base con raíces.
	EnemyBody.poly(g, [Vector2(-34, 30), Vector2(-22, 18), Vector2(22, 18), Vector2(34, 30), Vector2(10, 26),
			Vector2(0, 32), Vector2(-10, 26)])
	EnemyBody.poly(_bulb, EnemyBody.ellipse(Vector2(0, -2), Vector2(26, 24), 18))
	_mouth = Node2D.new()
	_mouth.position = Vector2(0, -26)
	_bulb.add_child(_mouth)
	EnemyBody.poly(_mouth, [Vector2(-10, 4), Vector2(-7, -18), Vector2(7, -18), Vector2(10, 4)])
	EnemyBody.poly(_bulb, EnemyBody.ellipse(Vector2(-9, -4), Vector2(3, 2.2), 10), Color(1.8, 0.7, 2.4))
	EnemyBody.poly(_bulb, EnemyBody.ellipse(Vector2(9, -4), Vector2(3, 2.2), 10), Color(1.8, 0.7, 2.4))


func _animate(target: Node2D) -> void:
	var swell := 0.0
	if target and _timer >= INTERVAL - TELEGRAPH:
		swell = (_timer - (INTERVAL - TELEGRAPH)) / TELEGRAPH
	var breathe := sin(_t * 3.0) * 0.03
	_bulb.scale = Vector2(1.0 + swell * 0.25 + breathe, 1.0 + swell * 0.18 - breathe)
	_mouth.scale.x = 1.0 + swell * 0.5
	if target:
		body.scale.x = 1.0 if target.global_position.x >= global_position.x else -1.0
