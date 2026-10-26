extends PlayerState
## Mantener curar en el suelo: al completarse gasta tinta y cura.

var _t: float = 0.0


func enter() -> void:
	_t = 0.0
	player.heal_started.emit()


func physics_update(delta: float) -> void:
	var p := player
	p.apply_gravity(delta)
	p.velocity.x = MovementMath.approach(p.velocity.x, 0.0, p.config.run_decel, delta)
	p.move()
	if not p.input.held(&"heal") or not p.is_on_floor():
		p.sm.transition(&"idle" if p.is_on_floor() else &"fall")
		return
	_t += delta
	if _t >= p.heal_duration():
		if p.ink.try_spend(p.ink.config.heal_cost):
			p.health.heal(p.ink.config.heal_amount)
			p.healed.emit()
		p.sm.transition(&"idle")
