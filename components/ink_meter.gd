class_name InkMeter
extends RefCounted
## Tinta, Inestabilidad y Desborde. Lógica pura: se avanza con tick(delta).

signal overflow_started()
signal overflow_ended()
signal vulnerability_ended()

enum State { NORMAL, OVERFLOW, VULNERABLE }

const MAX_INSTABILITY := 100.0

var config: InkConfig
var ink: float = 0.0
var instability: float = 0.0
var state: State = State.NORMAL
## Modificadores del árbol de habilidades.
var instability_gain_mult: float = 1.0
var overflow_duration_bonus: float = 0.0

var _timer: float = 0.0


func _init(cfg: InkConfig = null) -> void:
	config = cfg if cfg else InkConfig.new()


func gain(amount: float) -> void:
	if state == State.VULNERABLE:
		return
	ink = minf(ink + amount, config.max_ink)


func try_spend(amount: float) -> bool:
	if ink < amount:
		return false
	ink -= amount
	instability = maxf(instability - amount * config.spend_instability_reduction, 0.0)
	return true


func tick(delta: float) -> void:
	match state:
		State.NORMAL:
			if ink >= config.instability_threshold:
				instability += config.instability_rise_per_sec * instability_gain_mult * delta
			else:
				instability -= config.instability_decay_per_sec * delta
			instability = clampf(instability, 0.0, MAX_INSTABILITY)
			if instability >= MAX_INSTABILITY:
				_start_overflow()
		State.OVERFLOW:
			_timer -= delta
			if _timer <= 0.0:
				state = State.VULNERABLE
				instability = 0.0
				_timer = config.vulnerable_duration + _timer
				overflow_ended.emit()
		State.VULNERABLE:
			_timer -= delta
			if _timer <= 0.0:
				state = State.NORMAL
				_timer = 0.0
				vulnerability_ended.emit()


func damage_dealt_mult() -> float:
	if state == State.OVERFLOW:
		return config.overflow_damage_mult
	return 1.0 + 0.5 * instability / MAX_INSTABILITY


func damage_taken_mult() -> float:
	if state == State.VULNERABLE:
		return config.vulnerable_damage_taken_mult
	if state == State.OVERFLOW:
		return 1.0
	return 1.0 + 0.5 * instability / MAX_INSTABILITY


func speed_mult() -> float:
	if state == State.OVERFLOW:
		return config.overflow_speed_mult
	return 1.0 + 0.15 * instability / MAX_INSTABILITY


func reset() -> void:
	ink = 0.0
	instability = 0.0
	state = State.NORMAL
	_timer = 0.0


func _start_overflow() -> void:
	state = State.OVERFLOW
	instability = MAX_INSTABILITY
	ink = 0.0
	_timer = config.overflow_duration + overflow_duration_bonus
	overflow_started.emit()
