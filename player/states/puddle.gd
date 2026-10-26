extends PlayerState
## Forma charco: cuerpo disuelto que pasa por rejillas y grietas.

const SPEED := 620.0
const ENTRY_INVULNERABLE := 0.25


func enter() -> void:
	var p := player
	p.set_puddle_shape(true)
	p.invulnerable_timer = maxf(p.invulnerable_timer, ENTRY_INVULNERABLE)
	p.hurtbox.invulnerable = true
	if p.mods.puddle_contact_damage > 0.0:
		p.puddle_hitbox.damage = p.mods.puddle_contact_damage
		p.puddle_hitbox.activate()
	p.puddle_changed.emit(true)


func exit() -> void:
	var p := player
	p.set_puddle_shape(false)
	p.puddle_hitbox.deactivate()
	p.puddle_changed.emit(false)


func physics_update(delta: float) -> void:
	var p := player
	p.apply_gravity(delta)
	var dir := p.input.move_x()
	if dir != 0.0:
		p.facing = int(dir)
	p.velocity.x = MovementMath.approach(p.velocity.x, dir * SPEED, p.config.run_accel, delta)
	p.move()
	if not p.input.held(&"puddle") and p.can_stand():
		p.sm.transition(&"idle" if p.is_on_floor() else &"fall")
