class_name PlayerStateMachine
extends Node
## Máquina de estados del jugador. Cada hijo es un PlayerState.

signal state_changed(from: StringName, to: StringName)

var current: PlayerState
var states: Dictionary = {}


func setup(player: Player) -> void:
	for child in get_children():
		var s := child as PlayerState
		if s:
			s.player = player
			states[StringName(s.name.to_snake_case())] = s
	transition(&"idle")


func transition(state_name: StringName) -> void:
	var next: PlayerState = states.get(state_name)
	if next == null:
		push_warning("PlayerStateMachine: estado desconocido %s" % state_name)
		return
	var from := current.name if current else &""
	if current:
		current.exit()
	current = next
	current.enter()
	state_changed.emit(StringName(from.to_snake_case()), state_name)


func current_name() -> StringName:
	return StringName(current.name.to_snake_case()) if current else &""


func physics_update(delta: float) -> void:
	if current:
		current.physics_update(delta)
