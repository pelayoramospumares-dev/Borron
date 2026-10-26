extends GutTest


func test_jump_velocity() -> void:
	assert_almost_eq(MovementMath.jump_velocity(220, 0.36), -1222.2, 0.5)


func test_gravity() -> void:
	assert_almost_eq(MovementMath.gravity(220, 0.36), 3395.1, 0.5)


func test_approach_no_overshoot() -> void:
	assert_eq(MovementMath.approach(0, 100, 1000, 1.0), 100.0)
	assert_eq(MovementMath.approach(0, -100, 1000, 1.0), -100.0)
	assert_eq(MovementMath.approach(0, 100, 10, 1.0), 10.0)
