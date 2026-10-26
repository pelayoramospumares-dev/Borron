extends Room
## r04 · Pozo vertical: plataformas en zigzag y polillas.


func _init() -> void:
	room_id = &"r04"
	bounds = Rect2(0, 0, 1920, 2400)
	sky_top = Color(0.58, 0.6, 0.65)
	sky_bottom = Color(0.36, 0.37, 0.42)


func _build() -> void:
	solid(Rect2(-200, -200, 500, 2800))
	solid(Rect2(1620, -200, 500, 500))
	solid(Rect2(1620, 520, 500, 2100))
	solid(Rect2(-200, -400, 2400, 400))
	solid(Rect2(300, 2300, 500, 300))
	solid(Rect2(1000, 2300, 620, 300))
	var levels := [2120, 1940, 1760, 1580, 1400, 1220, 1040, 860]
	for i in levels.size():
		platform(500.0 if i % 2 == 0 else 1000.0, levels[i], 280)
	platform(1250, 690, 250)
	solid(Rect2(1380, 520, 240, 40))
	entry(&"bottom", Vector2(1150, 2240))
	entry(&"right", Vector2(1750, 470))
	transition(Rect2(800, 2380, 200, 100), &"r03", &"top")
	transition(Rect2(1910, 300, 100, 220), &"r05", &"left")
	enemy(&"flyer", Vector2(1200, 1500))
	enemy(&"flyer", Vector2(750, 1000))
	enemy(&"flyer", Vector2(1250, 560))
	recuerdo("a", Vector2(380, 1700))
	recuerdo("b", Vector2(1550, 1100), 2)
	far_skyline(1500, 5200.0)
	for y: float in [2300.0, 1700.0, 1100.0, 600.0]:
		column(rng.randf_range(500, 1400), y, rng.randf_range(500, 1200), rng.randf_range(300, 600))
		hanging_chain(rng.randf_range(400, 1500), y - 700, rng.randf_range(150, 600), rng.randf_range(150, 400))
	foreground_brush(600, 2300, 260)
