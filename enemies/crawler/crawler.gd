extends EnemyBase
## Patrullero: babosa de tinta con púas. Camina y se da la vuelta en paredes y bordes.

const HALF := Vector2(32, 22)

var dir: float = -1.0
var _t: float = 0.0
var _spikes: Node2D
var _legs: Array[Node2D] = []


func _ai(delta: float) -> void:
	_t += delta
	if is_on_floor() and (is_on_wall() or not _ground_ahead()):
		dir = -dir
	velocity.x = dir * stats.move_speed
	_animate()


func _ground_ahead() -> bool:
	var from := global_position + Vector2(dir * (HALF.x + 6), 0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, HALF.y + 24), 1)
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()


func _build_body(g: EnemyBody) -> void:
	# Cuerpo: joroba alargada.
	EnemyBody.poly(g, [Vector2(-34, 22), Vector2(34, 22), Vector2(36, 8), Vector2(24, -12),
			Vector2(4, -20), Vector2(-18, -16), Vector2(-32, -2)])
	_spikes = Node2D.new()
	g.add_child(_spikes)
	for i in 5:
		var x := -22.0 + i * 11.0
		EnemyBody.poly(_spikes, [Vector2(x - 4, -12), Vector2(x + 2, -34 + absf(i - 2) * 4), Vector2(x + 6, -12)])
	for i in 6:
		var leg := Node2D.new()
		leg.position = Vector2(-26 + i * 10, 12)
		g.add_child(leg)
		EnemyBody.poly(leg, [Vector2(-2, 0), Vector2(2, 0), Vector2(1, 10), Vector2(-1, 10)])
		_legs.append(leg)
	EnemyBody.poly(g, EnemyBody.ellipse(Vector2(26, -2), Vector2(2.5, 3.5), 10), Color(2.0, 1.7, 0.9))


func _animate() -> void:
	body.scale.x = -dir
	for i in _legs.size():
		_legs[i].rotation = sin(_t * 14.0 + i * 1.3) * 0.5
	_spikes.position.y = sin(_t * 7.0) * 1.5
	body.scale.y = 1.0 + sin(_t * 7.0) * 0.04
