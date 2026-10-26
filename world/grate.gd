class_name Grate
extends StaticBody2D
## Rejilla: bloquea al jugador salvo en forma charco (capa "grates").


func _ready() -> void:
	collision_layer = 32
	collision_mask = 0
