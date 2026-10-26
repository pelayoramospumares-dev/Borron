extends GutTest

const WorldScene := preload("res://world/world.tscn")
const ROOMS: Array[StringName] = [&"r01", &"r02", &"r03", &"r04", &"r05", &"r06", &"r07", &"r08", &"r09", &"r10"]

var _dir: String


func before_each() -> void:
	PlayerTestHelpers.release_all()
	HitStop.enabled = false
	_dir = "user://test_world_%d/" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(_dir)
	SaveManager.save_dir = _dir
	GameState.reset()


func after_each() -> void:
	get_tree().paused = false
	PlayerTestHelpers.release_all()
	HitStop.enabled = true
	for f: String in DirAccess.get_files_at(_dir):
		DirAccess.remove_absolute(_dir + f)
	DirAccess.remove_absolute(_dir)
	SaveManager.save_dir = "user://"
	GameState.reset()


func _room(id: StringName) -> Room:
	return load("res://world/zone1/%s.tscn" % id).instantiate()


func _world(room: StringName, entry: StringName) -> World:
	var w: World = WorldScene.instantiate()
	w.start_room = room
	w.start_entry = entry
	w.fade_time = 0.02
	add_child_autofree(w)
	return w


func test_all_rooms_load() -> void:
	for id in ROOMS:
		var r := _room(id)
		add_child_autofree(r)
		assert_eq(r.room_id, id)
		assert_gt(r.bounds.size.x, 1000.0, String(id))


func test_transitions_point_to_valid_entries() -> void:
	for id in ROOMS:
		var r := _room(id)
		add_child_autofree(r)
		for t: RoomTransition in r.transitions():
			var target := _room(t.target_room)
			add_child_autofree(target)
			assert_true(target.has_entry(t.target_entry), "%s -> %s:%s" % [id, t.target_room, t.target_entry])


func test_entries_not_inside_transitions() -> void:
	for id in ROOMS:
		var r := _room(id)
		add_child_autofree(r)
		for e: StringName in r.entry_names():
			for t: RoomTransition in r.transitions():
				assert_false(t.rect.has_point(r.get_entry(e)), "%s:%s dentro de una transición" % [id, e])


func test_world_starts_in_room() -> void:
	var w := _world(&"r01", &"start")
	await wait_physics_frames(4)
	assert_eq(w.room.room_id, &"r01")
	assert_true(w.player.is_on_floor())


func test_transition_preserves_puddle() -> void:
	GameState.unlock_ability(&"puddle")
	var w := _world(&"r01", &"right")
	await wait_physics_frames(4)
	Input.action_press("puddle")
	Input.action_press("move_right")
	for i in 240:
		await wait_physics_frames(1)
		if w.room.room_id == &"r02":
			break
	await wait_physics_frames(6)
	assert_eq(w.room.room_id, &"r02")
	assert_eq(w.player.sm.current_name(), &"puddle")


func test_tintero_saves_and_heals() -> void:
	var w := _world(&"r03", &"left")
	await wait_physics_frames(4)
	w.player.health.hp = 40
	var t := w.room.tintero()
	assert_not_null(t)
	t.rest(w.player)
	assert_true(w.skill_ui.is_open(), "descansar abre el árbol")
	w.skill_ui.close()
	assert_eq(w.player.health.hp, w.player.health.max_hp)
	assert_eq(GameState.last_tintero, &"r03")
	assert_true(SaveManager.has_save(0))


func test_pickup_not_respawned() -> void:
	var r := _room(&"r01")
	add_child(r)
	var pick: Recuerdo = r.recuerdos()[0]
	var id := pick.pickup_id
	pick.collect()
	r.free()
	var r2 := _room(&"r01")
	add_child_autofree(r2)
	await wait_process_frames(2)
	for p: Recuerdo in r2.recuerdos():
		assert_ne(p.pickup_id, id)


func test_zone_recuerdos_total_is_30() -> void:
	var total := BossArena.REWARD
	var ids: Dictionary = {}
	for id in ROOMS:
		var r := _room(id)
		add_child_autofree(r)
		for p: Recuerdo in r.recuerdos():
			total += p.value
			assert_false(ids.has(p.pickup_id), "id duplicado %s" % p.pickup_id)
			ids[p.pickup_id] = true
	assert_eq(total, 30)


func test_puddle_gate_requires_ability() -> void:
	var w := _world(&"r03", &"left")
	await wait_physics_frames(4)
	w.player.global_position = w.room.get_entry(&"grate_test")
	await wait_physics_frames(4)
	Input.action_press("move_right")
	await wait_physics_frames(360)
	assert_eq(w.room.room_id, &"r03")
	GameState.unlock_ability(&"puddle")
	Input.action_press("puddle")
	for i in 360:
		await wait_physics_frames(1)
		if w.room.room_id == &"r07":
			break
	assert_eq(w.room.room_id, &"r07")


func test_respawn_at_tintero_after_death() -> void:
	var w := _world(&"r03", &"left")
	await wait_physics_frames(4)
	w.room.tintero().rest(w.player)
	w.skill_ui.close()
	w.change_room(&"r02", &"right")
	await wait_physics_frames(20)
	assert_eq(w.room.room_id, &"r02")
	w.player.health.take_damage(1000)
	await wait_seconds(World.RESPAWN_DELAY + 0.4)
	assert_eq(w.room.room_id, &"r03")
	assert_eq(w.player.health.hp, w.player.health.max_hp)
	assert_almost_eq(w.player.global_position.x, w.room.tintero().global_position.x, 120.0)


func test_enemy_drop_spawns_recuerdo() -> void:
	var w := _world(&"r01", &"start")
	await wait_physics_frames(4)
	w.drop_chance_override = 1.0
	var dummy := Node2D.new()
	w.room.add_child(dummy)
	dummy.global_position = w.player.global_position + Vector2(200, 0)
	var before := w.room.recuerdos().size()
	EventBus.enemy_killed.emit(dummy)
	await wait_process_frames(2)
	assert_eq(w.room.recuerdos().size(), before + 1)
