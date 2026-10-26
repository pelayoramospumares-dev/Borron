class_name RoomTransition
extends Area2D
## Zona en el borde de una sala que lleva a otra sala/entrada.

@export var target_room: StringName
@export var target_entry: StringName
var rect: Rect2


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = rect.size
	cs.shape = r
	cs.position = rect.get_center()
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		var world := get_tree().get_first_node_in_group(&"world") as World
		if world:
			world.change_room.call_deferred(target_room, target_entry)
