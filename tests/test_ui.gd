extends GutTest

const PlayerScene := preload("res://player/player.tscn")

var player: Player
var _dir: String


func before_each() -> void:
	GameState.reset()
	_dir = "user://test_ui_%d/" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(_dir)
	SaveManager.save_dir = _dir
	player = PlayerScene.instantiate()
	add_child_autofree(player)


func after_each() -> void:
	get_tree().paused = false
	for f: String in DirAccess.get_files_at(_dir):
		DirAccess.remove_absolute(_dir + f)
	DirAccess.remove_absolute(_dir)
	SaveManager.save_dir = "user://"
	GameState.reset()


func _tree_ui() -> SkillTreeUI:
	var ui := SkillTreeUI.new()
	add_child_autofree(ui)
	ui.bind(player)
	return ui


func test_skill_ui_reflects_states() -> void:
	GameState.recuerdos = 2
	GameState.purchased_skills.append(&"marea_1")
	var ui := _tree_ui()
	ui.open()
	assert_eq(ui.node_state(&"marea_1"), &"purchased")
	assert_eq(ui.node_state(&"forma_1"), &"available")
	assert_eq(ui.node_state(&"forma_2"), &"locked")
	assert_eq(ui.node_state(&"marea_2"), &"locked")


func test_purchase_via_ui_updates_player() -> void:
	GameState.recuerdos = 5
	var ui := _tree_ui()
	ui.open()
	ui.press_node(&"forma_1")
	assert_eq(GameState.recuerdos, 5, "la primera pulsación solo selecciona")
	ui.press_node(&"forma_1")
	assert_eq(GameState.recuerdos, 3)
	assert_eq(player.health.max_hp, 120.0)
	assert_eq(ui.node_state(&"forma_1"), &"purchased")


func test_tree_pauses_and_closes() -> void:
	var ui := _tree_ui()
	ui.open()
	assert_true(get_tree().paused)
	ui.close()
	assert_false(get_tree().paused)


func test_tree_opens_on_rest() -> void:
	var ui := _tree_ui()
	EventBus.rested_at_tintero.emit(&"r03")
	assert_true(ui.is_open())
	ui.close()


func test_pause_stops_tree() -> void:
	var pm := PauseMenu.new()
	add_child_autofree(pm)
	pm.open()
	assert_true(get_tree().paused)
	pm.resume()
	assert_false(get_tree().paused)


func test_continue_hidden_without_save() -> void:
	var menu: MainMenu = load("res://ui/main_menu.tscn").instantiate()
	add_child_autofree(menu)
	assert_false(menu.continue_button.visible)


func test_continue_shown_with_save() -> void:
	SaveManager.save(0)
	var menu: MainMenu = load("res://ui/main_menu.tscn").instantiate()
	add_child_autofree(menu)
	assert_true(menu.continue_button.visible)


func test_hud_tracks_player() -> void:
	var hud := Hud.new()
	add_child_autofree(hud)
	hud.bind(player)
	player.health.hp = 50
	player.ink.ink = 66
	for i in 120:
		hud.advance(1.0 / 60.0)
	assert_almost_eq(hud.shown_health(), 0.5, 0.01)
	assert_almost_eq(hud.shown_ink(), 0.66, 0.01)


func _collect_texts(n: Node, out: Array[String]) -> void:
	if n is Label and (n as Label).visible:
		out.append((n as Label).text)
	if n is Button and (n as Button).visible:
		out.append((n as Button).text)
	for c in n.get_children():
		_collect_texts(c, out)


func test_all_ui_texts_translated() -> void:
	GameState.recuerdos = 3
	var ui := _tree_ui()
	ui.open()
	ui.press_node(&"voracidad_1")
	var pm := PauseMenu.new()
	add_child_autofree(pm)
	pm.open()
	var menu: MainMenu = load("res://ui/main_menu.tscn").instantiate()
	add_child_autofree(menu)
	var texts: Array[String] = []
	for n: Node in [ui, pm, menu]:
		_collect_texts(n, texts)
	assert_gt(texts.size(), 5)
	var key := RegEx.create_from_string("^[A-Z][A-Z0-9_]{3,}$")
	for t in texts:
		assert_null(key.search(t), "texto sin traducir: %s" % t)


func test_every_skill_has_translation() -> void:
	for n in SkillTree.load_all().nodes:
		assert_ne(tr(n.name_key), n.name_key)
		assert_ne(tr(n.desc_key), n.desc_key)
