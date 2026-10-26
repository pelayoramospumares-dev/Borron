extends Room
## r09 · Segundo Tintero, la calma antes del jefe.


func _init() -> void:
	room_id = &"r09"
	bounds = Rect2(0, 0, 2400, 1080)


func _build() -> void:
	solid(Rect2(-200, 900, 2800, 500))
	platform(1700, 700, 200)
	tintero_at(1200, 900)
	entry(&"left", Vector2(220, 852))
	entry(&"right", Vector2(2180, 852))
	transition(Rect2(-90, 500, 100, 400), &"r07", &"right")
	transition(Rect2(2390, 500, 100, 400), &"r10", &"left")
	recuerdo("a", Vector2(1800, 640))
	for x: float in [500.0, 1600.0, 2100.0]:
		lantern_post(x, 900, rng.randf_range(150, 400))
	decorate_outskirts(900, 0, 2400)
