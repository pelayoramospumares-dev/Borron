class_name GameCamera
extends Camera2D
## Cámara suave: sigue al objetivo con amortiguación independiente de los FPS,
## se anticipa en la dirección del movimiento, respeta los límites de la sala
## (centrándose si la sala es más pequeña que la vista) y tiembla con ruido.

@export var follow_speed: float = 7.0
@export var lookahead: float = 120.0
@export var lookahead_speed: float = 3.0
@export var vertical_bias: float = -60.0

var target: Node2D
var room_rect: Rect2 = Rect2(-100000, -100000, 200000, 200000)
## Solo para pruebas: tamaño de vista forzado.
var view_size_override: Vector2 = Vector2.ZERO

var _look: float = 0.0
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _shake_time: float = 0.0
var _noise := FastNoiseLite.new()
var _noise_t: float = 0.0


func _ready() -> void:
	_noise.frequency = 2.5
	# En 2D Godot interpola solo lo que se mueve en el paso de físicas.
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	position_smoothing_enabled = false
	ignore_rotation = true


func _process(delta: float) -> void:
	update_shake(delta)


func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		var focus: Vector2 = target.global_position
		var dir := 0.0
		if "facing" in target:
			dir = float(target.get("facing"))
		_look = lerpf(_look, dir * lookahead, 1.0 - exp(-lookahead_speed * delta))
		var desired := compute_target(focus + Vector2(_look, vertical_bias))
		global_position = global_position.lerp(desired, 1.0 - exp(-follow_speed * delta))


func set_room_limits(rect: Rect2) -> void:
	room_rect = rect


## Coloca la cámara directamente (al entrar en una sala).
func snap_to_target() -> void:
	if target:
		_look = 0.0
		global_position = compute_target(target.global_position + Vector2(0, vertical_bias))
		reset_physics_interpolation()


func view_size() -> Vector2:
	if view_size_override != Vector2.ZERO:
		return view_size_override
	return get_viewport_rect().size / zoom


func compute_target(focus: Vector2) -> Vector2:
	var half := view_size() * 0.5
	var out := focus
	if room_rect.size.x <= half.x * 2.0:
		out.x = room_rect.get_center().x
	else:
		out.x = clampf(focus.x, room_rect.position.x + half.x, room_rect.end.x - half.x)
	if room_rect.size.y <= half.y * 2.0:
		out.y = room_rect.get_center().y
	else:
		out.y = clampf(focus.y, room_rect.position.y + half.y, room_rect.end.y - half.y)
	return out


func shake(strength: float, duration: float) -> void:
	if strength < shake_strength():
		return
	_shake_strength = strength
	_shake_duration = maxf(duration, 0.001)
	_shake_time = _shake_duration


func shake_strength() -> float:
	if _shake_time <= 0.0:
		return 0.0
	var k := _shake_time / _shake_duration
	return _shake_strength * k * k


func update_shake(delta: float) -> void:
	_shake_time = maxf(_shake_time - delta, 0.0)
	var s := shake_strength()
	if s <= 0.0:
		offset = Vector2.ZERO
		return
	_noise_t += delta * 60.0
	offset = Vector2(_noise.get_noise_2d(_noise_t, 0.0), _noise.get_noise_2d(0.0, _noise_t)) * s * 2.0
