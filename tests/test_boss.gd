extends GutTest

const RoomScript := preload("res://tests/scenes/test_room.gd")
const PlayerScene := preload("res://player/player.tscn")
const ScribeScene := preload("res://bosses/scribe/scribe.tscn")

var room: Node2D


func before_each() -> void:
	PlayerTestHelpers.release_all()
	HitStop.enabled = false
	GameState.reset()
	room = Node2D.new()
	room.set_script(RoomScript)
	add_child_autofree(room)


func after_each() -> void:
	HitStop.enabled = true
	GameState.reset()


func _arena() -> BossArena:
	var arena := BossArena.new()
	arena.boss_id = &"scribe"
	arena.boss_scene = ScribeScene
	arena.boss_spawn = Vector2(-500, -110)
	arena.trigger_rect = Rect2(-1200, -400, 400, 400)
	arena.door_rects = [Rect2(-1450, -600, 40, 600)] as Array[Rect2]
	room.add_child(arena)
	return arena


func _hit(boss: EnemyBase, damage: float) -> void:
	var hb := Hitbox.new()
	hb.damage = damage
	boss.receive_hit(hb, Vector2.RIGHT)
	hb.free()


func test_phase_two_at_half_hp() -> void:
	var boss: Scribe = ScribeScene.instantiate()
	boss.position = Vector2(-800, -110)
	room.add_child(boss)
	await wait_physics_frames(2)
	assert_eq(boss.phase, 1)
	_hit(boss, 299)
	assert_eq(boss.phase, 1)
	_hit(boss, 2)
	assert_eq(boss.phase, 2)


func test_no_attack_repeated_thrice() -> void:
	var boss: Scribe = ScribeScene.instantiate()
	room.add_child(boss)
	for phase: int in [1, 2]:
		boss.phase = phase
		var history: Array[StringName] = []
		for i in 60:
			history.append(boss.pick_next_attack())
		for i in range(2, history.size()):
			assert_false(history[i] == history[i - 1] and history[i] == history[i - 2],
					"repetido 3 veces en %d" % i)


func test_wave_only_in_phase_two() -> void:
	var boss: Scribe = ScribeScene.instantiate()
	room.add_child(boss)
	boss.phase = 1
	for i in 60:
		assert_ne(boss.pick_next_attack(), &"ola")
	boss.phase = 2
	var seen := false
	for i in 60:
		if boss.pick_next_attack() == &"ola":
			seen = true
	assert_true(seen)


func test_arena_locks_on_enter() -> void:
	var arena := _arena()
	var player: Player = PlayerScene.instantiate()
	player.position = Vector2(-1500, -48)
	room.add_child(player)
	await wait_physics_frames(3)
	assert_false(arena.locked)
	player.global_position = Vector2(-1000, -48)
	await wait_physics_frames(4)
	assert_true(arena.locked)
	assert_not_null(arena.boss)


func test_defeat_emits_and_drops() -> void:
	var arena := _arena()
	var player: Player = PlayerScene.instantiate()
	player.position = Vector2(-1000, -48)
	room.add_child(player)
	await wait_physics_frames(4)
	watch_signals(EventBus)
	_hit(arena.boss, 1000)
	await wait_physics_frames(2)
	assert_signal_emitted_with_parameters(EventBus, "boss_defeated", [&"scribe"])
	assert_eq(GameState.recuerdos, 8)
	assert_has(GameState.bosses_defeated, &"scribe")
	assert_false(arena.locked)


func test_defeated_boss_not_respawned() -> void:
	GameState.bosses_defeated.append(&"scribe")
	var arena := _arena()
	var player: Player = PlayerScene.instantiate()
	player.position = Vector2(-1000, -48)
	room.add_child(player)
	await wait_physics_frames(4)
	assert_false(arena.locked)
	assert_null(arena.boss)


func test_player_death_resets_arena() -> void:
	var arena := _arena()
	var player: Player = PlayerScene.instantiate()
	player.position = Vector2(-1000, -48)
	room.add_child(player)
	await wait_physics_frames(4)
	assert_true(arena.locked)
	EventBus.player_died.emit()
	await wait_physics_frames(2)
	assert_false(arena.locked)
	assert_null(arena.boss)
