class_name MainMenu
extends Control
## Menú principal: Continuar (si hay partida) / Nueva partida / Salir.

const WorldScene := preload("res://world/world.tscn")

var continue_button: Button
var _new_button: Button


func _ready() -> void:
	theme = UiStyle.theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.07)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var ash := InkParticles.create(&"ambient_ash")
	ash.position = Vector2(960, 540)
	add_child(ash)
	ash.emitting = true
	var title := UiStyle.label("Borrón", 120)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-500, 200)
	title.size = Vector2(1000, 150)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var sub := UiStyle.label(tr("MENU_SUBTITLE"), 28, UiStyle.DIM)
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.position = Vector2(-500, 350)
	sub.size = Vector2(1000, 40)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(sub)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-200, 40)
	box.size = Vector2(400, 260)
	box.add_theme_constant_override(&"separation", 14)
	add_child(box)
	continue_button = UiStyle.button(tr("UI_CONTINUE"), 34)
	continue_button.pressed.connect(_continue)
	continue_button.visible = SaveManager.has_save(0)
	box.add_child(continue_button)
	_new_button = UiStyle.button(tr("UI_NEW_GAME"), 34)
	_new_button.pressed.connect(_new_game)
	box.add_child(_new_button)
	var quit := UiStyle.button(tr("UI_QUIT"), 34)
	quit.pressed.connect(func() -> void: get_tree().quit())
	box.add_child(quit)
	var focus := continue_button if continue_button.visible else _new_button
	focus.grab_focus.call_deferred()


func _continue() -> void:
	SaveManager.load(0)
	var w: World = WorldScene.instantiate()
	if GameState.last_tintero != &"":
		w.start_room = GameState.last_tintero
		w.start_entry = &"tintero"
	_switch_to(w)


func _new_game() -> void:
	GameState.reset()
	_switch_to(WorldScene.instantiate())


func _switch_to(node: Node) -> void:
	var tree := get_tree()
	tree.root.add_child(node)
	tree.current_scene = node
	queue_free()
