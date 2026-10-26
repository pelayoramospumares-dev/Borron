class_name SkillTreeUI
extends CanvasLayer
## Árbol de la Tinta: se abre al descansar en un Tintero. Tres columnas
## (Forma, Marea, Voracidad). Pulsar un nodo lo selecciona; pulsarlo otra vez
## lo aprende. Navegable con teclado y mando (acciones ui_*).

const BRANCHES: Array[StringName] = [&"forma", &"marea", &"voracidad"]
const BRANCH_COLORS := {
	&"forma": Color(0.75, 0.8, 0.95),
	&"marea": Color(0.55, 0.8, 0.85),
	&"voracidad": Color(0.95, 0.5, 0.6),
}

var tree_data: SkillTree
var _player: Player
var _root: Control
var _buttons: Dictionary = {}
var _selected: StringName = &""
var _recuerdos_label: Label
var _name_label: Label
var _desc_label: Label
var _status_label: Label


func _ready() -> void:
	layer = 55
	process_mode = Node.PROCESS_MODE_ALWAYS
	tree_data = SkillTree.load_all()
	_build()
	_root.visible = false
	EventBus.rested_at_tintero.connect(func(_id: StringName) -> void: open())


func bind(p: Player) -> void:
	_player = p


func is_open() -> bool:
	return _root.visible


func open() -> void:
	_root.visible = true
	get_tree().paused = true
	_selected = &""
	_refresh()
	var first: Button = _buttons[&"forma_1"]
	first.grab_focus.call_deferred()


func close() -> void:
	_root.visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and (event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause")):
		close()
		get_viewport().set_input_as_handled()


## "purchased", "available" o "locked".
func node_state(id: StringName) -> StringName:
	if tree_data.is_purchased(id):
		return &"purchased"
	var n := tree_data.get_node_by_id(id)
	for req in n.requires:
		if not tree_data.is_purchased(req):
			return &"locked"
	if n.requires_ability != &"" and not GameState.has_ability(n.requires_ability):
		return &"locked"
	return &"available"


func press_node(id: StringName) -> void:
	if _selected == id and tree_data.can_purchase(id):
		tree_data.purchase(id)
		if _player:
			_player.refresh_mods()
	_selected = id
	_refresh()


func _refresh() -> void:
	_recuerdos_label.text = tr("TREE_RECUERDOS") % GameState.recuerdos
	for id: StringName in _buttons:
		var b: Button = _buttons[id]
		var n := tree_data.get_node_by_id(id)
		var st := node_state(id)
		b.text = "%s\n%d" % [tr(n.name_key), n.cost] if st != &"purchased" else "%s\n✓" % tr(n.name_key)
		var col: Color = BRANCH_COLORS[StringName(n.branch)]
		match st:
			&"purchased":
				b.modulate = col
			&"available":
				b.modulate = Color(1, 1, 1, 1)
			_:
				b.modulate = Color(1, 1, 1, 0.35)
	if _selected == &"":
		_name_label.text = ""
		_desc_label.text = ""
		_status_label.text = ""
		return
	var sel := tree_data.get_node_by_id(_selected)
	_name_label.text = tr(sel.name_key)
	_desc_label.text = tr(sel.desc_key)
	match node_state(_selected):
		&"purchased":
			_status_label.text = tr("TREE_BOUGHT")
		&"locked":
			var needs_ability := sel.requires_ability != &"" and not GameState.has_ability(sel.requires_ability)
			_status_label.text = tr("TREE_NEED_ABILITY") if needs_ability else tr("TREE_LOCKED")
		_:
			if GameState.recuerdos < sel.cost:
				_status_label.text = "%s · %s" % [tr("TREE_COST") % sel.cost, tr("TREE_NOT_ENOUGH")]
			else:
				_status_label.text = "%s · %s" % [tr("TREE_COST") % sel.cost, tr("TREE_BUY_HINT")]


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.theme = UiStyle.theme()
	add_child(_root)
	_root.add_child(UiStyle.backdrop(0.9))
	var title := UiStyle.label(tr("TREE_TITLE"), 56)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-400, 60)
	title.size = Vector2(800, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(title)
	_recuerdos_label = UiStyle.label("", 28, UiStyle.ACCENT)
	_recuerdos_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_recuerdos_label.position = Vector2(-400, 132)
	_recuerdos_label.size = Vector2(800, 40)
	_recuerdos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(_recuerdos_label)
	var cols := HBoxContainer.new()
	cols.set_anchors_preset(Control.PRESET_CENTER)
	cols.position = Vector2(-540, -250)
	cols.size = Vector2(1080, 480)
	cols.add_theme_constant_override(&"separation", 60)
	cols.alignment = BoxContainer.ALIGNMENT_CENTER
	_root.add_child(cols)
	for branch in BRANCHES:
		var col := VBoxContainer.new()
		col.custom_minimum_size = Vector2(300, 0)
		col.add_theme_constant_override(&"separation", 22)
		cols.add_child(col)
		var head := UiStyle.label(tr("BRANCH_%s" % String(branch).to_upper()), 36, BRANCH_COLORS[branch])
		head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(head)
		for i in 3:
			var id := StringName("%s_%d" % [branch, i + 1])
			var b := UiStyle.button("", 26)
			b.custom_minimum_size = Vector2(300, 96)
			b.pressed.connect(press_node.bind(id))
			b.focus_entered.connect(func() -> void:
				if _selected != id:
					_selected = id
					_refresh())
			col.add_child(b)
			_buttons[id] = b
	var info := VBoxContainer.new()
	info.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	info.position = Vector2(-500, -250)
	info.size = Vector2(1000, 180)
	info.add_theme_constant_override(&"separation", 8)
	_root.add_child(info)
	_name_label = UiStyle.label("", 34, UiStyle.ACCENT)
	_desc_label = UiStyle.label("", 26)
	_status_label = UiStyle.label("", 22, UiStyle.DIM)
	for l: Label in [_name_label, _desc_label, _status_label]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		info.add_child(l)
	var close_label := UiStyle.label(tr("TREE_CLOSE"), 20, UiStyle.DIM)
	close_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	close_label.position = Vector2(-320, -60)
	close_label.size = Vector2(300, 30)
	_root.add_child(close_label)
