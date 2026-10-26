extends Room
## r08 · Sala secreta (solo accesible en charco desde r07).


func _init() -> void:
	room_id = &"r08"
	bounds = Rect2(0, 0, 1920, 1080)
	sky_top = Color(0.36, 0.36, 0.42)
	sky_bottom = Color(0.2, 0.2, 0.24)
	fog_color = Color(0.4, 0.4, 0.46)


func _build() -> void:
	solid(Rect2(-200, -200, 2400, 260))
	solid(Rect2(-200, 900, 2400, 500))
	solid(Rect2(1900, -200, 300, 1500))
	solid(Rect2(1440, 780, 120, 120))
	entry(&"top", Vector2(960, 150))
	entry(&"left", Vector2(220, 852))
	transition(Rect2(-90, 500, 100, 400), &"r07", &"from_secret")
	recuerdo("tesoro", Vector2(1500, 700), 5)
	for x: float in [300.0, 800.0, 1300.0, 1700.0]:
		column(x, 900, rng.randf_range(300, 800), rng.randf_range(300, 600), false)
	hanging_chain(600, 60, 200, 300)
	hanging_chain(1500, 60, 400, 220)
