extends GutTest


func test_physics_settings() -> void:
	assert_eq(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"), 120)
	assert_true(ProjectSettings.get_setting("physics/common/physics_interpolation"))
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 1920)


func test_input_actions_exist() -> void:
	for a: String in ["move_left", "move_right", "move_up", "move_down", "jump", "attack",
			"dash", "heal", "puddle", "interact", "pause", "debug_fps"]:
		assert_true(InputMap.has_action(a), a)
