extends GutTest

var cam: GameCamera


func before_each() -> void:
	cam = GameCamera.new()
	add_child_autofree(cam)
	cam.set_room_limits(Rect2(0, 0, 2400, 1080))


func test_clamps_inside_room() -> void:
	cam.view_size_override = Vector2(1920, 1080)
	var t := cam.compute_target(Vector2(100, 900))
	assert_eq(t, Vector2(960, 540))
	t = cam.compute_target(Vector2(2390, 50))
	assert_eq(t, Vector2(1440, 540))


func test_camera_clamped_ultrawide() -> void:
	# 3440×1440 con aspecto "expand" desde 1920×1080 → 2580×1080 visibles.
	cam.view_size_override = Vector2(2580, 1080)
	var t := cam.compute_target(Vector2(300, 500))
	assert_eq(t.x, 1200.0, "sala más estrecha que la vista: centrada")
	assert_eq(t.y, 540.0)


func test_camera_clamped_16_10() -> void:
	# 1920×1200 → 1920×1200 visibles: la sala (1080 de alto) queda centrada en vertical.
	cam.view_size_override = Vector2(1920, 1200)
	var t := cam.compute_target(Vector2(2000, 100))
	assert_eq(t, Vector2(1440, 540))


func test_shake_decays_to_zero() -> void:
	cam.shake(10.0, 0.3)
	cam.update_shake(0.1)
	assert_gt(cam.offset.length(), 0.0)
	cam.update_shake(0.25)
	assert_eq(cam.offset, Vector2.ZERO)


func test_stronger_shake_wins() -> void:
	cam.shake(10.0, 0.3)
	cam.shake(2.0, 0.1)
	assert_eq(cam.shake_strength(), 10.0)


func test_follows_target_in_tree() -> void:
	var t := Node2D.new()
	t.position = Vector2(1500, 500)
	add_child_autofree(t)
	cam.view_size_override = Vector2(1920, 1080)
	cam.target = t
	cam.global_position = Vector2(960, 540)
	await wait_physics_frames(30)
	assert_gt(cam.global_position.x, 1000.0)
