extends PlayerState


func physics_update(delta: float) -> void:
	var p := player
	p.apply_gravity(delta)
	p.apply_horizontal(delta)
	p.move()
	if p.try_common_actions():
		return
	if not p.is_on_floor():
		p.sm.transition(&"fall")
	elif p.input.move_x() != 0.0:
		p.sm.transition(&"run")
