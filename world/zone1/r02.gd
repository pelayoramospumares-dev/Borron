extends Room
## r02 · Primeros patrulleros.


func _init() -> void:
	room_id = &"r02"
	bounds = Rect2(0, 0, 3200, 1080)


func _build() -> void:
	solid(Rect2(-200, 900, 3600, 500))
	platform(600, 720, 260)
	platform(1100, 580, 240)
	solid(Rect2(1500, 760, 400, 140))
	platform(2100, 640, 300)
	solid(Rect2(2600, 780, 300, 120))
	entry(&"left", Vector2(220, 852))
	entry(&"right", Vector2(2980, 852))
	transition(Rect2(-90, 500, 100, 400), &"r01", &"right")
	transition(Rect2(3190, 500, 100, 400), &"r03", &"left")
	enemy(&"crawler", Vector2(900, 876))
	enemy(&"crawler", Vector2(1700, 736))
	enemy(&"crawler", Vector2(2400, 876))
	recuerdo("a", Vector2(1220, 520))
	recuerdo("b", Vector2(2250, 590))
	decorate_outskirts(900, 0, 3200)
