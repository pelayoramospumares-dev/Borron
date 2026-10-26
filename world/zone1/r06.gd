extends Room
## r06 · Santuario de la forma charco: chimenea para saltar entre paredes y,
## tras conseguir el charco, una rejilla en el suelo que baja a r07.


func _init() -> void:
	room_id = &"r06"
	bounds = Rect2(0, 0, 2880, 1080)


func _build() -> void:
	solid(Rect2(-200, 900, 2600, 500))
	solid(Rect2(2560, 900, 520, 500))
	solid(Rect2(900, 300, 80, 600))
	solid(Rect2(1200, 150, 80, 750))
	solid(Rect2(1280, 150, 700, 40))
	solid(Rect2(2860, -200, 300, 1500))
	floor_grate(2400, 900, 160)
	shrine(&"puddle", 1650, 150)
	entry(&"left", Vector2(220, 852))
	transition(Rect2(-90, 500, 100, 400), &"r05", &"right")
	transition(Rect2(2400, 1040, 160, 100), &"r07", &"top")
	enemy(&"crawler", Vector2(2200, 876))
	recuerdo("a", Vector2(1900, 90), 2)
	decorate_outskirts(900, 0, 2880)
	painted_backdrop(900)
