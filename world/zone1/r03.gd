extends Room
## r03 · Primer Tintero. Subida hacia r04 y pasillo bloqueado por una rejilla
## (solo se atraviesa en forma charco) hacia r07.


func _init() -> void:
	room_id = &"r03"
	bounds = Rect2(0, 0, 3200, 1080)


func _build() -> void:
	solid(Rect2(-200, 900, 3600, 500))
	solid(Rect2(-200, -200, 1800, 360))
	solid(Rect2(1800, -200, 1600, 360))
	solid(Rect2(2450, 160, 950, 540))
	platform(200, 700, 200)
	platform(1400, 720, 200)
	platform(1700, 560, 200)
	platform(1450, 400, 200)
	platform(1600, 250, 190)
	platform(2100, 560, 220)
	grate(2650, 900)
	tintero_at(900, 900)
	entry(&"left", Vector2(220, 852))
	entry(&"top", Vector2(1700, 190))
	entry(&"right", Vector2(3000, 852))
	entry(&"grate_test", Vector2(2550, 852))
	transition(Rect2(-90, 500, 100, 400), &"r02", &"right")
	transition(Rect2(1600, -120, 200, 100), &"r04", &"bottom")
	transition(Rect2(3190, 700, 100, 200), &"r07", &"left")
	enemy(&"crawler", Vector2(450, 876))
	enemy(&"spitter", Vector2(2300, 866))
	recuerdo("a", Vector2(300, 650))
	recuerdo("b", Vector2(2210, 510))
	decorate_outskirts(900, 0, 2400)
