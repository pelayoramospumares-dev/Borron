class_name EnemyBase
extends CharacterBody2D
## Base de los enemigos: vida, golpes, retroceso, destello, muerte y reinicio.
## Las subclases construyen su cuerpo en _build_body() y su IA en _ai(delta).

const GRAVITY := 2600.0
const MAX_FALL := 1100.0
const KNOCKBACK := 260.0

@export var stats: EnemyStats
@export var uses_gravity: bool = true

var health: Health = Health.new()
var spawn_position: Vector2
var dead: bool = false
var body: EnemyBody
var hurtbox: Hurtbox
var contact_hitbox: Hitbox
var _knock_timer: float = 0.0


func _ready() -> void:
	if stats == null:
		stats = EnemyStats.new()
	collision_layer = 4
	collision_mask = 33
	spawn_position = global_position
	health.max_hp = stats.max_hp
	health.reset()
	health.died.connect(_die)
	body = EnemyBody.new()
	add_child(body)
	_build_body(body)
	hurtbox = Hurtbox.new()
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 8
	add_child(hurtbox)
	hurtbox.owner = self
	hurtbox.add_child(_shape_copy())
	hurtbox.hit.connect(func(hb: Hitbox) -> void:
		var dir := signf(global_position.x - hb.global_position.x)
		receive_hit(hb, Vector2(dir if dir != 0.0 else 1.0, 0)))
	contact_hitbox = Hitbox.new()
	contact_hitbox.damage = stats.contact_damage
	contact_hitbox.collision_layer = 16
	contact_hitbox.collision_mask = 0
	contact_hitbox.monitoring = false
	contact_hitbox.source = self
	add_child(contact_hitbox)
	contact_hitbox.owner = self
	contact_hitbox.add_child(_shape_copy(0.85))


func _physics_process(delta: float) -> void:
	if dead:
		return
	if uses_gravity:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	if _knock_timer > 0.0:
		_knock_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
	else:
		_ai(delta)
	move_and_slide()


func receive_hit(hb: Hitbox, dir: Vector2) -> void:
	if dead:
		return
	health.take_damage(hb.damage)
	if body:
		body.flash()
	if not dead:
		velocity.x = dir.x * KNOCKBACK
		_knock_timer = 0.15
		_on_hurt()


## Vuelve a su sitio con la vida llena (lo usan los Tinteros).
func reset_enemy() -> void:
	dead = false
	global_position = spawn_position
	velocity = Vector2.ZERO
	reset_physics_interpolation()
	health.reset()
	visible = true
	hurtbox.set_deferred(&"monitoring", true)
	contact_hitbox.set_deferred(&"monitorable", true)
	_knock_timer = 0.0
	_on_reset()


func find_player() -> Node2D:
	return get_tree().get_first_node_in_group(&"player") as Node2D


func player_in_range(r: float) -> Node2D:
	var p := find_player()
	if p and p.global_position.distance_to(global_position) <= r:
		return p
	return null


func _die() -> void:
	dead = true
	visible = false
	hurtbox.set_deferred(&"monitoring", false)
	contact_hitbox.monitorable = false
	EventBus.enemy_killed.emit(self)


## Forma de colisión del cuerpo (las subclases la definen en la escena).
func _shape_copy(scale_factor: float = 1.0) -> CollisionShape2D:
	var src := get_node(^"Collision") as CollisionShape2D
	var cs := CollisionShape2D.new()
	var shape := src.shape.duplicate() as Shape2D
	if shape is RectangleShape2D:
		(shape as RectangleShape2D).size *= scale_factor
	elif shape is CircleShape2D:
		(shape as CircleShape2D).radius *= scale_factor
	cs.shape = shape
	cs.position = src.position
	return cs


# --- Para las subclases -------------------------------------------------------

func _build_body(_group: EnemyBody) -> void:
	pass


func _ai(_delta: float) -> void:
	pass


func _on_hurt() -> void:
	pass


func _on_reset() -> void:
	pass
