class_name Hitbox
extends Area2D
## Zona que hace daño a los Hurtbox que toca.

signal landed(hurtbox: Hurtbox)

@export var damage: float = 10.0
@export var knockback: float = 300.0
## Si es true, cada activación golpea a cada objetivo una sola vez (ataques).
## Si es false, golpea mientras haya contacto (daño por contacto).
@export var once_per_activation: bool = false
var source: Node
var _hit: Array[Hurtbox] = []


func activate() -> void:
	_hit.clear()
	monitorable = true


func deactivate() -> void:
	monitorable = false


func can_hit(hurtbox: Hurtbox) -> bool:
	return not (once_per_activation and _hit.has(hurtbox))


func register_hit(hurtbox: Hurtbox) -> void:
	_hit.append(hurtbox)
	landed.emit(hurtbox)
