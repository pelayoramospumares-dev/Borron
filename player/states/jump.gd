extends PlayerState


func physics_update(delta: float) -> void:
	var p := player
	if p.input.released(&"jump") and p.velocity.y < 0.0:
		p.velocity.y *= p.config.jump_cut_mult
	p.apply_gravity(delta)
	p.apply_horizontal(delta)
	p.move()
	if p.try_common_actions():
		return
	if p.velocity.y >= 0.0:
		p.sm.transition(&"fall")
