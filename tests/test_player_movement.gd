extends GutTest

const PlayerScene := preload("res://player/player.tscn")
const RoomScript := preload("res://tests/scenes/test_room.gd")

var room: Node2D
var player: Player


func before_each() -> void:
	PlayerTestHelpers.release_all()
	room = Node2D.new()
	room.set_script(RoomScript)
	add_child_autofree(room)
	player = PlayerScene.instantiate()
	player.position = Vector2(-800, -48)
	room.add_child(player)
	await wait_physics_frames(6)


func after_each() -> void:
	PlayerTestHelpers.release_all()


func _floor_height() -> float:
	# Distancia del pie del jugador al suelo (y=0); positiva = por encima.
	return -(player.global_position.y + 48.0)


func test_starts_on_floor() -> void:
	assert_true(player.is_on_floor())


func test_reaches_run_speed() -> void:
	Input.action_press("move_right")
	await wait_physics_frames(30)
	assert_almost_eq(player.velocity.x, 520.0, 1.0)


func test_jump_apex_height() -> void:
	Input.action_press("jump")
	var max_h := 0.0
	for i in 70:
		await wait_physics_frames(1)
		max_h = maxf(max_h, _floor_height())
	assert_almost_eq(max_h, 220.0, 8.0)


func test_short_hop() -> void:
	Input.action_press("jump")
	await wait_physics_frames(3)
	Input.action_release("jump")
	var max_h := 0.0
	for i in 60:
		await wait_physics_frames(1)
		max_h = maxf(max_h, _floor_height())
	assert_gt(max_h, 20.0)
	assert_lt(max_h, 120.0)


func test_coyote_jump() -> void:
	player.global_position = Vector2(150, -48)
	await wait_physics_frames(roundi(0.08 * 120))
	Input.action_press("jump")
	await wait_physics_frames(2)
	assert_lt(player.velocity.y, 0.0)


func test_no_jump_after_coyote() -> void:
	player.global_position = Vector2(150, -48)
	await wait_physics_frames(roundi(0.15 * 120))
	Input.action_press("jump")
	await wait_physics_frames(2)
	assert_gt(player.velocity.y, 0.0)


func test_jump_buffer() -> void:
	player.global_position = Vector2(-800, -78)
	player.velocity = Vector2.ZERO
	await wait_physics_frames(1)
	Input.action_press("jump")
	await wait_physics_frames(2)
	Input.action_release("jump")
	var max_h := 0.0
	for i in 40:
		await wait_physics_frames(1)
		max_h = maxf(max_h, _floor_height())
	assert_gt(max_h, 60.0)


func test_dash_distance() -> void:
	var x0 := player.global_position.x
	Input.action_press("dash")
	await wait_physics_frames(40)
	assert_almost_eq(player.global_position.x - x0, 144.0, 10.0)


func test_dash_cooldown() -> void:
	Input.action_press("dash")
	await wait_physics_frames(2)
	Input.action_release("dash")
	await wait_physics_frames(30)
	var x0 := player.global_position.x
	Input.action_press("dash")
	await wait_physics_frames(10)
	assert_almost_eq(player.global_position.x, x0, 1.0)


func test_wall_slide_speed_cap() -> void:
	player.global_position = Vector2(-1440, -900)
	player.velocity = Vector2.ZERO
	Input.action_press("move_left")
	await wait_physics_frames(60)
	assert_true(player.is_on_wall())
	assert_eq(player.sm.current_name(), &"wall_slide")
	assert_almost_eq(player.velocity.y, 180.0, 0.5)


func test_wall_jump_pushes_away() -> void:
	player.global_position = Vector2(-1440, -900)
	Input.action_press("move_left")
	await wait_physics_frames(30)
	Input.action_press("jump")
	await wait_physics_frames(3)
	assert_gt(player.velocity.x, 0.0)
	assert_lt(player.velocity.y, 0.0)
