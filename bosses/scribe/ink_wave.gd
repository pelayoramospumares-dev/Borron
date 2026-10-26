class_name InkWave
extends Hitbox
## Ola de tinta que recorre el suelo; hay que saltarla.

const SPEED := 620.0
const LIFETIME := 3.0
const SIZE := Vector2(60, 56)

var direction: float = 1.0
var _age: float = 0.0
var _shape: Polygon2D


func _init() -> void:
	collision_layer = 16
	collision_mask = 1
	damage = 25.0
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = SIZE
	cs.shape = r
	add_child(cs)
	var body := EnemyBody.new()
	add_child(body)
	_shape = EnemyBody.poly(body, [Vector2(-34, 28), Vector2(34, 28), Vector2(26, 0), Vector2(10, -30),
			Vector2(0, -20), Vector2(-12, -34), Vector2(-24, -6)])


func _ready() -> void:
	body_entered.connect(func(_b: Node) -> void: queue_free())


func _physics_process(delta: float) -> void:
	_age += delta
	global_position.x += direction * SPEED * delta
	_shape.scale = Vector2(direction, 1.0 + sin(_age * 25.0) * 0.12)
	if _age >= LIFETIME:
		queue_free()
