class_name InkProjectile
extends Hitbox
## Proyectil de tinta en arco. Se destruye al tocar el mundo o al jugador.

const GRAVITY := 900.0
const FLIGHT_TIME := 0.9
const LIFETIME := 4.0

var velocity: Vector2 = Vector2.ZERO
var _age: float = 0.0


func _init() -> void:
	collision_layer = 16
	collision_mask = 1
	damage = 20.0
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 10.0
	cs.shape = c
	add_child(cs)
	var body := EnemyBody.new()
	add_child(body)
	EnemyBody.poly(body, EnemyBody.ellipse(Vector2.ZERO, Vector2(11, 11), 14))


func _ready() -> void:
	body_entered.connect(func(_b: Node) -> void: _splash())
	landed.connect(func(_h: Hurtbox) -> void: _splash())


## Velocidad inicial para llegar a `target` en FLIGHT_TIME segundos.
static func launch_velocity(from: Vector2, target: Vector2) -> Vector2:
	var t := FLIGHT_TIME
	var d := target - from
	return Vector2(d.x / t, (d.y - 0.5 * GRAVITY * t * t) / t)


func _physics_process(delta: float) -> void:
	_age += delta
	velocity.y += GRAVITY * delta
	global_position += velocity * delta
	rotation = velocity.angle()
	if _age > LIFETIME:
		queue_free()


func _splash() -> void:
	EventBus.hit_landed.emit(global_position, 0.6)
	queue_free()
