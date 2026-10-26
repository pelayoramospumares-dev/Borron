class_name Health
extends RefCounted
## Vida de una entidad. Lógica pura, sin nodos.

signal damaged(amount: float)
signal healed(amount: float)
signal died()

var max_hp: float = 100.0
var hp: float = 100.0
var damage_taken_mult: float = 1.0


func take_damage(amount: float) -> float:
	if is_dead():
		return 0.0
	var real := amount * damage_taken_mult
	hp = maxf(hp - real, 0.0)
	damaged.emit(real)
	if is_dead():
		died.emit()
	return real


func heal(amount: float) -> void:
	if is_dead():
		return
	var before := hp
	hp = minf(hp + amount, max_hp)
	healed.emit(hp - before)


func reset() -> void:
	hp = max_hp


func is_dead() -> bool:
	return hp <= 0.0
