class_name Player
extends CharacterBody2D
## Protagonista. La lógica de cada estado vive en player/states/.

signal landed(impact_speed: float)
signal jumped()
signal dashed()
signal wall_jumped()
signal attacked(direction: StringName)
signal attack_landed(target: Node, position: Vector2)
signal heal_started()
signal healed()
signal hurt(amount: float)
signal died()

const HALF_HEIGHT := 48.0
const BASE_HP := 100.0
const BASE_DAMAGE := 10.0
const ATTACK_COOLDOWN := 0.32
const INVULNERABLE_TIME := 1.0
const KNOCKBACK := Vector2(420, -380)
## Tamaños de hitbox de ataque (lateral; arriba/abajo).
const ATTACK_SIDE := Vector2(110, 70)
const ATTACK_VERTICAL := Vector2(80, 110)
const POGO_HEIGHT := 150.0
const POGO_APEX := 0.3

@export var config: MovementConfig = preload("res://player/movement_config.tres")
@export var ink_config: InkConfig = preload("res://components/ink_config.tres")

var mods: StatMods = StatMods.new()
var input: PlayerInput = PlayerInput.new()
var facing: int = 1
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var air_dash_available: bool = true
var wall_jump_lock_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var invulnerable_timer: float = 0.0
var health: Health = Health.new()
var ink: InkMeter

@onready var sm: PlayerStateMachine = $StateMachine
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var _attack_shape: CollisionShape2D = $AttackHitbox/Shape


func _ready() -> void:
	ink = InkMeter.new(ink_config)
	health.max_hp = BASE_HP
	health.reset()
	health.died.connect(_on_died)
	hurtbox.hit.connect(_on_hurtbox_hit)
	attack_hitbox.source = self
	attack_hitbox.landed.connect(_on_attack_landed)
	attack_hitbox.deactivate()
	refresh_mods()
	sm.setup(self)


func _physics_process(delta: float) -> void:
	input.poll()
	_update_timers(delta)
	ink.tick(delta)
	health.damage_taken_mult = ink.damage_taken_mult()
	sm.physics_update(delta)


func refresh_mods() -> void:
	mods = SkillTree.load_all().compute_mods()
	health.max_hp = BASE_HP + mods.max_hp_bonus
	health.hp = minf(health.hp, health.max_hp)
	ink.instability_gain_mult = mods.instability_gain_mult
	ink.overflow_duration_bonus = mods.overflow_duration_bonus


func speed_mult() -> float:
	return ink.speed_mult()


func is_dead() -> bool:
	return sm.current_name() == &"dead"


func heal_duration() -> float:
	return ink.config.heal_time * mods.heal_time_mult


func attack_damage() -> float:
	return BASE_DAMAGE * ink.damage_dealt_mult() * mods.damage_mult


func prepare_attack_hitbox(direction: StringName) -> void:
	var rect := _attack_shape.shape as RectangleShape2D
	var r := mods.attack_range_mult
	match direction:
		&"up":
			rect.size = ATTACK_VERTICAL * r
			attack_hitbox.position = Vector2(0, -HALF_HEIGHT - rect.size.y * 0.5 + 20)
		&"down":
			rect.size = ATTACK_VERTICAL * r
			attack_hitbox.position = Vector2(0, HALF_HEIGHT + rect.size.y * 0.5 - 20)
		_:
			rect.size = ATTACK_SIDE * r
			attack_hitbox.position = Vector2(facing * (20 + rect.size.x * 0.5), 0)
	attack_hitbox.damage = attack_damage()
	attack_hitbox.set_meta("direction", direction)


## Reaparece en `at` con vida e Inestabilidad reiniciadas.
func respawn(at: Vector2) -> void:
	global_position = at
	velocity = Vector2.ZERO
	reset_physics_interpolation()
	ink.reset()
	health.damage_taken_mult = 1.0
	health.reset()
	invulnerable_timer = INVULNERABLE_TIME
	hurtbox.invulnerable = true
	sm.transition(&"idle")
	EventBus.player_respawned.emit()


func gravity() -> float:
	return MovementMath.gravity(config.jump_height, config.time_to_apex)


func apply_gravity(delta: float) -> void:
	var g := gravity()
	if velocity.y > 0.0:
		g *= config.fall_gravity_mult
	velocity.y = minf(velocity.y + g * delta, config.max_fall_speed)


func apply_horizontal(delta: float, can_turn: bool = true) -> void:
	var dir := input.move_x()
	if wall_jump_lock_timer > 0.0:
		return
	if dir != 0.0 and can_turn:
		facing = int(dir)
	var target := dir * config.run_speed * speed_mult()
	var rate: float
	if is_on_floor():
		rate = config.run_accel if dir != 0.0 else config.run_decel
	else:
		rate = config.air_accel
	velocity.x = MovementMath.approach(velocity.x, target, rate, delta)


func move() -> void:
	move_and_slide()
	if is_on_floor():
		coyote_timer = config.coyote_time
		air_dash_available = true


func can_dash() -> bool:
	return dash_cooldown_timer <= 0.0 and (is_on_floor() or air_dash_available)


func can_jump() -> bool:
	return is_on_floor() or coyote_timer > 0.0


## Saltos y dash disponibles desde casi cualquier estado. Devuelve true si cambió de estado.
func try_common_actions() -> bool:
	if input.pressed(&"attack") and attack_cooldown_timer <= 0.0:
		sm.transition(&"attack")
		return true
	if input.held(&"heal") and is_on_floor() and ink.ink >= ink.config.heal_cost \
			and sm.current_name() != &"heal":
		sm.transition(&"heal")
		return true
	if input.pressed(&"dash") and can_dash():
		sm.transition(&"dash")
		return true
	if jump_buffer_timer > 0.0 and can_jump():
		do_jump()
		return true
	return false


func do_jump() -> void:
	velocity.y = MovementMath.jump_velocity(config.jump_height, config.time_to_apex)
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	jumped.emit()
	sm.transition(&"jump")


func do_wall_jump(away_dir: float) -> void:
	velocity = Vector2(config.wall_jump_velocity.x * away_dir, config.wall_jump_velocity.y)
	facing = int(away_dir)
	wall_jump_lock_timer = config.wall_jump_lock
	jump_buffer_timer = 0.0
	wall_jumped.emit()
	sm.transition(&"jump")


func _update_timers(delta: float) -> void:
	if input.pressed(&"jump"):
		jump_buffer_timer = config.jump_buffer
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)
	if not is_on_floor():
		coyote_timer = maxf(coyote_timer - delta, 0.0)
	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)
	wall_jump_lock_timer = maxf(wall_jump_lock_timer - delta, 0.0)
	attack_cooldown_timer = maxf(attack_cooldown_timer - delta, 0.0)
	if invulnerable_timer > 0.0:
		invulnerable_timer = maxf(invulnerable_timer - delta, 0.0)
		hurtbox.invulnerable = invulnerable_timer > 0.0


func _on_attack_landed(target: Hurtbox) -> void:
	ink.gain(ink.config.ink_per_hit * mods.ink_gain_mult)
	var pos := target.global_position
	attack_landed.emit(target.owner, pos)
	EventBus.hit_landed.emit(pos, 1.0)
	HitStop.trigger(0.05)
	if attack_hitbox.get_meta("direction", &"side") == &"down":
		velocity.y = MovementMath.jump_velocity(POGO_HEIGHT, POGO_APEX)
		air_dash_available = air_dash_available or mods.dash_refresh_on_hit
		if mods.dash_refresh_on_hit:
			dash_cooldown_timer = 0.0
	elif mods.dash_refresh_on_hit:
		air_dash_available = true
		dash_cooldown_timer = 0.0


func _on_hurtbox_hit(hb: Hitbox) -> void:
	if is_dead():
		return
	var real := health.take_damage(hb.damage)
	hurt.emit(real)
	if health.is_dead():
		return
	invulnerable_timer = INVULNERABLE_TIME
	hurtbox.invulnerable = true
	var away := signf(global_position.x - hb.global_position.x)
	if away == 0.0:
		away = -float(facing)
	velocity = Vector2(away * KNOCKBACK.x, KNOCKBACK.y)
	HitStop.trigger(0.08)
	sm.transition(&"hurt")


func _on_died() -> void:
	sm.transition(&"dead")
	died.emit()
	EventBus.player_died.emit()
