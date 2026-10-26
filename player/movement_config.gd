class_name MovementConfig
extends Resource
## Valores ajustables del movimiento del jugador.

@export var run_speed: float = 520.0
@export var run_accel: float = 4200.0
@export var run_decel: float = 5200.0
@export var air_accel: float = 3200.0
@export var jump_height: float = 220.0
@export var time_to_apex: float = 0.36
@export var fall_gravity_mult: float = 1.6
@export var jump_cut_mult: float = 0.45
@export var max_fall_speed: float = 1100.0
@export var coyote_time: float = 0.10
@export var jump_buffer: float = 0.12
@export var dash_speed: float = 900.0
@export var dash_time: float = 0.16
@export var dash_cooldown: float = 0.35
@export var wall_slide_speed: float = 180.0
@export var wall_jump_velocity: Vector2 = Vector2(480, -620)
@export var wall_jump_lock: float = 0.14
