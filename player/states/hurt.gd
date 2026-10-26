extends PlayerState
## Retroceso breve tras recibir daño; sin control.

const DURATION := 0.2

var _t: float = 0.0


func enter() -> void:
	_t = 0.0


func physics_update(delta: float) -> void:
	var p := player
	_t += delta
	p.apply_gravity(delta)
	p.velocity.x = MovementMath.approach(p.velocity.x, 0.0, p.config.air_accel, delta)
	p.move()
	if _t >= DURATION:
		p.sm.transition(&"idle" if p.is_on_floor() else &"fall")
