class_name FpsCounter
extends CanvasLayer
## Contador de FPS de depuración (F3).

var _label: Label


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.position = Vector2(16, 12)
	_label.add_theme_font_size_override(&"font_size", 22)
	_label.visible = false
	add_child(_label)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"debug_fps"):
		_label.visible = not _label.visible
	if _label.visible:
		_label.text = "%d FPS" % Engine.get_frames_per_second()
