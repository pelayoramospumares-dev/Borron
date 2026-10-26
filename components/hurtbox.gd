class_name Hurtbox
extends Area2D
## Zona que recibe golpes de los Hitbox.

signal hit(hitbox: Hitbox)

var invulnerable: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if invulnerable:
		return
	var hb := area as Hitbox
	if hb and hb.source != owner:
		hit.emit(hb)
