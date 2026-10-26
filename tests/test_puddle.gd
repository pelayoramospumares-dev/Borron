extends GutTest

const PlayerScene := preload("res://player/player.tscn")
const RoomScript := preload("res://tests/scenes/test_room.gd")
const ShrineScene := preload("res://world/ability_shrine.tscn")

var room: Node2D
var player: Player


func before_each() -> void:
	PlayerTestHelpers.release_all()
	GameState.reset()
	room = Node2D.new()
	room.set_script(RoomScript)
	add_child_autofree(room)
	player = PlayerScene.instantiate()
	player.position = Vector2(-800, -48)
	room.add_child(player)
	await wait_physics_frames(6)


func after_each() -> void:
	PlayerTestHelpers.release_all()
	GameState.reset()


func test_cannot_puddle_without_ability() -> void:
	Input.action_press("puddle")
	await wait_physics_frames(5)
	assert_ne(player.sm.current_name(), &"puddle")


func test_puddle_passes_grate() -> void:
	room.add_grate()
	GameState.unlock_ability(&"puddle")
	Input.action_press("puddle")
	Input.action_press("move_right")
	await wait_physics_frames(60)
	assert_eq(player.sm.current_name(), &"puddle")
	assert_gt(player.global_position.x, -580.0)


func test_grate_blocks_normal() -> void:
	room.add_grate()
	Input.action_press("move_right")
	await wait_physics_frames(60)
	assert_lt(player.global_position.x, -600.0)


func _enter_tunnel_as_puddle() -> void:
	room.add_low_tunnel()
	GameState.unlock_ability(&"puddle")
	player.global_position = Vector2(-1000, -48)
	await wait_physics_frames(4)
	Input.action_press("puddle")
	Input.action_press("move_left")
	await wait_physics_frames(36)
	Input.action_release("move_left")
	await wait_physics_frames(10)


func test_cannot_unpuddle_under_low_ceiling() -> void:
	await _enter_tunnel_as_puddle()
	assert_between(player.global_position.x, -1290.0, -1110.0)
	Input.action_release("puddle")
	await wait_physics_frames(10)
	assert_eq(player.sm.current_name(), &"puddle")


func test_unpuddle_when_space() -> void:
	await _enter_tunnel_as_puddle()
	Input.action_release("puddle")
	Input.action_press("move_right")
	await wait_physics_frames(40)
	Input.action_release("move_right")
	await wait_physics_frames(20)
	assert_gt(player.global_position.x, -1060.0)
	assert_ne(player.sm.current_name(), &"puddle")


func test_puddle_brief_invulnerability() -> void:
	GameState.unlock_ability(&"puddle")
	Input.action_press("puddle")
	await wait_physics_frames(2)
	assert_true(player.hurtbox.invulnerable)


func test_shrine_unlocks_once() -> void:
	watch_signals(EventBus)
	var shrine: AbilityShrine = ShrineScene.instantiate()
	shrine.ability_id = &"puddle"
	room.add_child(shrine)
	shrine.activate()
	shrine.activate()
	assert_true(GameState.has_ability(&"puddle"))
	assert_signal_emit_count(EventBus, "ability_unlocked", 1)
