class_name Hitbox
extends Area2D
## Zona que hace daño a los Hurtbox que toca.

@export var damage: float = 10.0
@export var knockback: float = 300.0
var source: Node
