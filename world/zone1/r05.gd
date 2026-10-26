extends Room
## r05 · Tiradores en terrazas.


func _init() -> void:
	room_id = &"r05"
	bounds = Rect2(0, 0, 3000, 1080)


func _build() -> void:
	solid(Rect2(-200, 900, 3400, 500))
	solid(Rect2(700, 720, 500, 180))
	solid(Rect2(1500, 560, 500, 340))
	solid(Rect2(2300, 720, 400, 180))
	platform(2750, 560, 200)
	entry(&"left", Vector2(220, 852))
	entry(&"right", Vector2(2780, 852))
	transition(Rect2(-90, 500, 100, 400), &"r04", &"right")
	transition(Rect2(2990, 500, 100, 400), &"r06", &"left")
	enemy(&"spitter", Vector2(950, 686))
	enemy(&"spitter", Vector2(1750, 526))
	enemy(&"spitter", Vector2(2600, 866))
	enemy(&"flyer", Vector2(2000, 300))
	recuerdo("a", Vector2(1750, 380))
	recuerdo("b", Vector2(2850, 500), 2)
	decorate_outskirts(900, 0, 3000)
