extends GutTest

var spawner: VfxSpawner


func before_each() -> void:
	spawner = VfxSpawner.new()
	add_child_autofree(spawner)


func test_hit_spawns_splash() -> void:
	EventBus.hit_landed.emit(Vector2(100, 100), 1.0)
	await wait_process_frames(1)
	var found := false
	for c in spawner.get_children():
		if c.name.begins_with("HitSplash"):
			found = true
	assert_true(found)


func test_all_effects_build() -> void:
	for kind: StringName in InkParticles.KINDS:
		var p := InkParticles.create(kind)
		assert_not_null(p, String(kind))
		assert_true(p is GPUParticles2D)
		p.free()


func test_one_shot_frees_itself() -> void:
	var p := spawner.burst(&"land_splash", Vector2.ZERO)
	assert_true(is_instance_valid(p))
	await wait_seconds(p.lifetime + 0.6)
	assert_false(is_instance_valid(p))


func test_decal_cap() -> void:
	var decals := SplatterDecals.new()
	add_child_autofree(decals)
	for i in 100:
		decals.add_splat(Vector2(i * 10, 0), Vector2.UP, 1.0)
	assert_lte(decals.get_child_count(), SplatterDecals.MAX_SPLATS)


func test_slash_frees_itself() -> void:
	var s := SlashArc.new()
	s.direction = &"side"
	add_child(s)
	await wait_seconds(SlashArc.DURATION + 0.1)
	assert_false(is_instance_valid(s))


func test_tracks_bound_player() -> void:
	var player: Player = preload("res://player/player.tscn").instantiate()
	add_child_autofree(player)
	await wait_physics_frames(1)
	spawner.bind_player(player)
	player.global_position = Vector2(300, 200)
	await wait_physics_frames(3)
	assert_almost_eq(spawner.get_node(^"DashTrail").global_position, player.global_position, Vector2(12, 12))
