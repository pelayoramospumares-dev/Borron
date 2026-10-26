extends Node
## Congela el juego un instante en los impactos (sensación de golpe).

const SLOW_SCALE := 0.05

var enabled: bool = true
var _until_ms: int = 0


func trigger(duration: float) -> void:
	if not enabled:
		return
	var end := Time.get_ticks_msec() + int(duration * 1000.0)
	_until_ms = maxi(_until_ms, end)
	Engine.time_scale = SLOW_SCALE


func _process(_delta: float) -> void:
	if Engine.time_scale != 1.0 and Time.get_ticks_msec() >= _until_ms:
		Engine.time_scale = 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
