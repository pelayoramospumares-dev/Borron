extends Room
## r07 · El atajo: conecta con r03 por la rejilla y esconde una rejilla en el
## suelo que lleva a la sala secreta r08.


func _init() -> void:
	room_id = &"r07"
	bounds = Rect2(0, 0, 3600, 1080)


func _build() -> void:
	solid(Rect2(-200, -200, 4000, 260))
	solid(Rect2(-200, 900, 1600, 500))
	solid(Rect2(1520, 900, 2280, 500))
	solid(Rect2(-200, 60, 400, 640))
	floor_grate(1400, 900, 120)
	platform(500, 700, 200)
	platform(2500, 720, 200)
	platform(2900, 560, 220)
	entry(&"left", Vector2(260, 852))
	entry(&"top", Vector2(2000, 120))
	entry(&"right", Vector2(3380, 852))
	entry(&"from_secret", Vector2(1250, 852))
	transition(Rect2(-90, 700, 100, 200), &"r03", &"right")
	transition(Rect2(3590, 500, 100, 400), &"r09", &"left")
	transition(Rect2(1400, 1040, 120, 100), &"r08", &"top")
	enemy(&"crawler", Vector2(900, 876))
	enemy(&"crawler", Vector2(2600, 876))
	enemy(&"flyer", Vector2(2200, 400))
	recuerdo("a", Vector2(600, 640))
	recuerdo("b", Vector2(3010, 500))
	decorate_outskirts(900, 200, 3600)
