class_name PauseMenu
extends CanvasLayer
## Menú de pausa: Continuar / Volver al menú.

signal to_menu()

var _root: Control
var _resume: Button


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	_root.add_child(UiStyle.backdrop(0.7))
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-200, -120)
	box.size = Vector2(400, 240)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override(&"separation", 18)
	_root.add_child(box)
	var title := UiStyle.label(tr("UI_PAUSED"), 54)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_resume = UiStyle.button(tr("UI_RESUME"))
	_resume.pressed.connect(resume)
	box.add_child(_resume)
	var menu := UiStyle.button(tr("UI_TO_MENU"))
	menu.pressed.connect(func() -> void:
		resume()
		to_menu.emit())
	box.add_child(menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		if _root.visible:
			resume()
		elif not get_tree().paused:
			open()
		get_viewport().set_input_as_handled()


func open() -> void:
	_root.visible = true
	get_tree().paused = true
	_resume.grab_focus.call_deferred()


func resume() -> void:
	_root.visible = false
	get_tree().paused = false


func is_open() -> bool:
	return _root.visible
