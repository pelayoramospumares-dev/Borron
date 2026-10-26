extends PlayerState
## Ataque en tres direcciones. Anticipación breve, golpe activo y recuperación.

const WINDUP := 0.05
const ACTIVE_END := 0.15
const DURATION := 0.28

var direction: StringName = &"side"
var _t: float = 0.0


func enter() -> void:
	var p := player
	_t = 0.0
	p.attack_cooldown_timer = p.ATTACK_COOLDOWN
	if p.input.axis.y < -0.5:
		direction = &"up"
	elif p.input.axis.y > 0.5 and not p.is_on_floor():
		direction = &"down"
	else:
		direction = &"side"
	p.prepare_attack_hitbox(direction)


func elapsed() -> float:
	return _t


func exit() -> void:
	player.attack_hitbox.deactivate()


func physics_update(delta: float) -> void:
	var p := player
	var was := _t
	_t += delta
	if was < WINDUP and _t >= WINDUP:
		p.attack_hitbox.activate()
		p.attacked.emit(direction)
	if was < ACTIVE_END and _t >= ACTIVE_END:
		p.attack_hitbox.deactivate()
	if p.input.released(&"jump") and p.velocity.y < 0.0:
		p.velocity.y *= p.config.jump_cut_mult
	p.apply_gravity(delta)
	p.apply_horizontal(delta, false)
	p.move()
	if p.input.pressed(&"dash") and p.can_dash():
		p.sm.transition(&"dash")
		return
	if p.jump_buffer_timer > 0.0 and p.can_jump():
		p.do_jump()
		return
	if _t >= DURATION:
		if p.is_on_floor():
			p.sm.transition(&"idle")
		else:
			p.sm.transition(&"jump" if p.velocity.y < 0.0 else &"fall")
