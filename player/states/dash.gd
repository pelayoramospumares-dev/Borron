extends PlayerState

var _timer: float = 0.0
var _dir: float = 1.0


func enter() -> void:
	var p := player
	_dir = p.input.move_x() if p.input.move_x() != 0.0 else float(p.facing)
	p.facing = int(_dir)
	_timer = p.config.dash_time * p.mods.dash_distance_mult
	p.dash_cooldown_timer = p.config.dash_cooldown
	p.air_dash_available = p.is_on_floor()
	p.velocity = Vector2(_dir * p.config.dash_speed, 0.0)
	p.dashed.emit()


func physics_update(delta: float) -> void:
	var p := player
	p.velocity = Vector2(_dir * p.config.dash_speed, 0.0)
	p.move()
	_timer -= delta
	if _timer <= 0.0 or p.is_on_wall():
		p.velocity.x = _dir * p.config.run_speed * minf(absf(p.input.move_x()), 1.0)
		p.sm.transition(&"idle" if p.is_on_floor() else &"fall")
