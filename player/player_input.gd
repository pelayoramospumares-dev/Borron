class_name PlayerInput
extends RefCounted
## Lee el estado de las acciones una vez por tick de físicas y calcula
## pulsaciones y liberaciones propias (independientes del frame de render).

const ACTIONS: Array[StringName] = [&"jump", &"attack", &"dash", &"heal", &"puddle", &"interact"]

var axis: Vector2 = Vector2.ZERO
var _held: Dictionary = {}
var _prev: Dictionary = {}


func poll() -> void:
	axis = Vector2(
		Input.get_axis(&"move_left", &"move_right"),
		Input.get_axis(&"move_up", &"move_down"))
	_prev = _held.duplicate()
	for a in ACTIONS:
		_held[a] = Input.is_action_pressed(a)


func held(action: StringName) -> bool:
	return _held.get(action, false)


func pressed(action: StringName) -> bool:
	return _held.get(action, false) and not _prev.get(action, false)


func released(action: StringName) -> bool:
	return not _held.get(action, false) and _prev.get(action, false)


func move_x() -> float:
	if absf(axis.x) < 0.3:
		return 0.0
	return signf(axis.x)
