extends Room
## r01 · Despertar: tutorial de movimiento (escalón, foso, saltos).


func _init() -> void:
	room_id = &"r01"
	bounds = Rect2(0, 0, 3000, 1080)


func _build() -> void:
	solid(Rect2(-200, -400, 200, 1700))
	solid(Rect2(-200, 900, 1300, 500))
	solid(Rect2(780, 820, 320, 80))
	solid(Rect2(1100, 1010, 220, 400))
	solid(Rect2(1320, 900, 700, 500))
	solid(Rect2(1700, 620, 120, 280))
	solid(Rect2(2020, 700, 1200, 700))
	entry(&"start", Vector2(200, 852))
	entry(&"right", Vector2(2780, 652))
	transition(Rect2(2990, 300, 120, 400), &"r02", &"left")
	recuerdo("a", Vector2(1210, 960))
	recuerdo("b", Vector2(1760, 570))
	enemy(&"crawler", Vector2(2450, 676))
	decorate_outskirts(900, 0, 3000)
