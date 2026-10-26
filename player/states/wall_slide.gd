extends PlayerState

var wall_dir: float = 0.0


func enter() -> void:
	wall_dir = -player.get_wall_normal().x
	player.facing = int(-wall_dir)


func physics_update(delta: float) -> void:
	var p := player
	p.apply_gravity(delta)
	p.velocity.y = minf(p.velocity.y, p.config.wall_slide_speed)
	p.velocity.x = wall_dir * 50.0
	p.move()
	if p.jump_buffer_timer > 0.0:
		p.do_wall_jump(-wall_dir)
		return
	if p.input.pressed(&"dash") and p.can_dash():
		p.sm.transition(&"dash")
		return
	if p.is_on_floor():
		p.sm.transition(&"idle")
	elif not p.is_on_wall() or p.input.move_x() != wall_dir:
		p.sm.transition(&"fall")
