class_name Hurtbox
extends Area2D
## Zona que recibe golpes de los Hitbox que la solapan.

signal hit(hitbox: Hitbox)

var invulnerable: bool = false


func _init() -> void:
	monitorable = false


func _physics_process(_delta: float) -> void:
	if invulnerable or not monitoring:
		return
	for area in get_overlapping_areas():
		var hb := area as Hitbox
		if hb == null or not hb.monitorable or (hb.source != null and hb.source == owner):
			continue
		if not hb.can_hit(self):
			continue
		hb.register_hit(self)
		hit.emit(hb)
		if invulnerable:
			return
