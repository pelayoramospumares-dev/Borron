class_name Player
extends CharacterBody2D
## Protagonista. La lógica de cada estado vive en player/states/.

signal landed(impact_speed: float)
signal jumped()
signal dashed()
signal wall_jumped()

const HALF_HEIGHT := 48.0

@export var config: MovementConfig = preload("res://player/movement_config.tres")

var mods: StatMods = StatMods.new()
var input: PlayerInput = PlayerInput.new()
var facing: int = 1
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var air_dash_available: bool = true
var wall_jump_lock_timer: float = 0.0

@onready var sm: PlayerStateMachine = $StateMachine


func _ready() -> void:
	refresh_mods()
	sm.setup(self)


func _physics_process(delta: float) -> void:
	input.poll()
	_update_timers(delta)
	sm.physics_update(delta)


func refresh_mods() -> void:
	mods = SkillTree.load_all().compute_mods()


func speed_mult() -> float:
	return 1.0


func gravity() -> float:
	return MovementMath.gravity(config.jump_height, config.time_to_apex)


func apply_gravity(delta: float) -> void:
	var g := gravity()
	if velocity.y > 0.0:
		g *= config.fall_gravity_mult
	velocity.y = minf(velocity.y + g * delta, config.max_fall_speed)


func apply_horizontal(delta: float) -> void:
	var dir := input.move_x()
	if wall_jump_lock_timer > 0.0:
		return
	if dir != 0.0:
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
