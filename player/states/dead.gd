extends PlayerState
## Muerto: cae al suelo y espera a que el mundo lo reaparezca.


func enter() -> void:
	player.attack_hitbox.deactivate()


func physics_update(delta: float) -> void:
	var p := player
	p.apply_gravity(delta)
	p.velocity.x = MovementMath.approach(p.velocity.x, 0.0, p.config.run_decel, delta)
	p.move()
