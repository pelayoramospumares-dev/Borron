extends GutTest

var _dir: String


func before_each() -> void:
	_dir = "user://test_saves_%d/" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(_dir)
	SaveManager.save_dir = _dir
	GameState.reset()


func after_each() -> void:
	for f: String in DirAccess.get_files_at(_dir):
		DirAccess.remove_absolute(_dir + f)
	DirAccess.remove_absolute(_dir)
	SaveManager.save_dir = "user://"
	GameState.reset()


func _write(text: String) -> void:
	var f := FileAccess.open(_dir + "save_0.json", FileAccess.WRITE)
	f.store_string(text)
	f.close()


func test_roundtrip() -> void:
	GameState.recuerdos = 7
	GameState.abilities = [&"puddle"]
	GameState.last_tintero = &"t1"
	GameState.purchased_skills = [&"forma_1"]
	assert_true(SaveManager.save(0))
	GameState.reset()
	assert_true(SaveManager.load(0))
	assert_eq(GameState.recuerdos, 7)
	assert_true(GameState.has_ability(&"puddle"))
	assert_eq(GameState.last_tintero, &"t1")
	assert_has(GameState.purchased_skills, &"forma_1")


func test_missing_file_starts_new_game() -> void:
	GameState.recuerdos = 3
	assert_false(SaveManager.load(0))
	assert_eq(GameState.recuerdos, 0)


func test_corrupt_file_starts_new_game() -> void:
	_write("{no json")
	assert_false(SaveManager.load(0))
	assert_eq(GameState.recuerdos, 0)


func test_wrong_version_starts_new_game() -> void:
	_write('{"version": 99, "recuerdos": 50}')
	assert_false(SaveManager.load(0))
	assert_eq(GameState.recuerdos, 0)


func test_atomic_write_leaves_no_tmp() -> void:
	SaveManager.save(0)
	assert_false(FileAccess.file_exists(_dir + "save_0.json.tmp"))
	assert_true(SaveManager.has_save(0))


func test_add_recuerdos_emits() -> void:
	watch_signals(EventBus)
	GameState.add_recuerdos(4)
	assert_eq(GameState.recuerdos, 4)
	assert_signal_emitted_with_parameters(EventBus, "recuerdos_changed", [4])
