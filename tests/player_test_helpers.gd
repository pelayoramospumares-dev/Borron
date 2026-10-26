class_name PlayerTestHelpers
## Utilidades para pruebas que simulan al jugador en la sala de pruebas.

static func release_all() -> void:
	for a: StringName in InputMap.get_actions():
		Input.action_release(a)
