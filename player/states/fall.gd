extends PlayerState


func physics_update(delta: float) -> void:
	var p := player
	p.apply_gravity(delta)
	p.apply_horizontal(delta)
	var impact := p.velocity.y
	p.move()
	if p.is_on_floor():
		p.landed.emit(impact)
		if p.jump_buffer_timer > 0.0:
			p.do_jump()
			return
		p.sm.transition(&"run" if p.input.move_x() != 0.0 else &"idle")
		return
	if p.try_common_actions():
		return
	if p.is_on_wall_only() and p.input.move_x() == -p.get_wall_normal().x and p.velocity.y > 0.0:
		p.sm.transition(&"wall_slide")
