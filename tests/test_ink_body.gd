extends GutTest

const STATES: Array[StringName] = [&"idle", &"run", &"jump", &"fall", &"wall_slide", &"dash",
		&"attack", &"heal", &"puddle", &"hurt", &"dead"]

var body: InkBody


func before_each() -> void:
	body = InkBody.new()
	add_child_autofree(body)


func test_shader_compiles() -> void:
	var shader: Shader = load("res://player/body/ink_body.gdshader")
	assert_not_null(shader)
	var mat := ShaderMaterial.new()
	mat.shader = shader
	assert_true(shader.get_shader_uniform_list().size() > 0)


func test_all_poses_defined() -> void:
	for s in STATES:
		for vy: float in [-600.0, 0.0, 600.0]:
			var pose := PoseLibrary.pose_name_for(s, vy, &"side", 0.1)
			assert_true(PoseLibrary.POSES.has(pose), "%s -> %s" % [s, pose])
	for d: StringName in [&"side", &"up", &"down"]:
		assert_true(PoseLibrary.POSES.has(PoseLibrary.pose_name_for(&"attack", 0.0, d, 0.0)))
		assert_true(PoseLibrary.POSES.has(PoseLibrary.pose_name_for(&"attack", 0.0, d, 0.2)))


func test_instability_maps_to_wobble() -> void:
	body.set_instability(100.0)
	assert_almost_eq(body.wobble_amount(), 7.5, 0.001)
	body.set_instability(0.0)
	assert_almost_eq(body.wobble_amount(), 1.5, 0.001)


func test_pose_blend_is_continuous() -> void:
	body.snap_to_pose(&"idle")
	var start := body.channel(&"arm_f")
	var target: float = deg_to_rad(PoseLibrary.POSES[&"attack_up"][&"arm_f"])
	body.set_pose_target(&"attack_up")
	body.advance(1.0 / 120.0)
	var moved := absf(body.channel(&"arm_f") - start)
	assert_gt(moved, 0.0)
	assert_lt(moved, absf(target - start) * 0.25)


func test_pose_converges() -> void:
	body.snap_to_pose(&"idle")
	body.set_pose_target(&"fall")
	for i in 120:
		body.advance(1.0 / 120.0)
	assert_almost_eq(body.channel(&"arm_f"), deg_to_rad(PoseLibrary.POSES[&"fall"][&"arm_f"]), 0.02)


func test_large_delta_is_stable() -> void:
	body.snap_to_pose(&"idle")
	body.set_pose_target(&"dash")
	body.advance(0.25)
	assert_true(absf(body.channel(&"arm_f")) < TAU)


func test_drip_count_grows_with_instability() -> void:
	body.set_instability(0.0)
	var low := body.drip_segments()
	body.set_instability(100.0)
	assert_gt(body.drip_segments(), low)
