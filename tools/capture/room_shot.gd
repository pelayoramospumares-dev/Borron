extends Node
## Captura una sala del mundo. --out=/ruta.png --room=r01 --entry=start [--walk=frames]

func _ready() -> void:
	var w: World = load("res://world/world.tscn").instantiate()
	w.start_room = StringName(CaptureUtil.arg("room", "r01"))
	w.start_entry = StringName(CaptureUtil.arg("entry", "start"))
	add_child(w)
	var walk := int(CaptureUtil.arg("walk", "0"))
	for k in 30:
		await get_tree().physics_frame
	if walk != 0:
		Input.action_press("move_right" if walk > 0 else "move_left")
		for k in absi(walk):
			await get_tree().physics_frame
		Input.action_release("move_right")
		Input.action_release("move_left")
	for k in 20:
		await get_tree().process_frame
	CaptureUtil.save(self, CaptureUtil.arg("out", "user://room.png"))
	get_tree().quit()
