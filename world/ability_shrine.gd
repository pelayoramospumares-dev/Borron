class_name AbilityShrine
extends Area2D
## Santuario que concede una habilidad llave al interactuar.

signal activated(ability_id: StringName)

@export var ability_id: StringName = &"puddle"


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	_refresh_visual()


func _physics_process(_delta: float) -> void:
	if GameState.has_ability(ability_id):
		return
	if Input.is_action_just_pressed(&"interact") and _player_inside():
		activate()


func activate() -> void:
	if GameState.has_ability(ability_id):
		return
	GameState.unlock_ability(ability_id)
	activated.emit(ability_id)
	_refresh_visual()


func _player_inside() -> bool:
	for body in get_overlapping_bodies():
		if body is Player:
			return true
	return false


func _refresh_visual() -> void:
	var glow := get_node_or_null(^"Glow") as CanvasItem
	if glow:
		glow.visible = not GameState.has_ability(ability_id)
