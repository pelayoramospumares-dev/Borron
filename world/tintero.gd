class_name Tintero
extends Area2D
## Tintero: farol apagado donde descansar. Cura, guarda la partida, reinicia
## los enemigos de la sala y abre el árbol de habilidades.

signal rested()

var room_id: StringName
var _flame: Polygon2D
var _light: PointLight2D
var _prompt: Label
var _player_near: bool = false
var _t: float = 0.0


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(160, 160)
	cs.shape = r
	cs.position = Vector2(0, -80)
	add_child(cs)
	_build_visual()
	_prompt = Label.new()
	_prompt.text = "▲"
	_prompt.position = Vector2(-8, -230)
	_prompt.add_theme_font_size_override(&"font_size", 26)
	_prompt.modulate = Color(1, 1, 1, 0)
	add_child(_prompt)
	body_entered.connect(func(b: Node) -> void: if b is Player: _player_near = true)
	body_exited.connect(func(b: Node) -> void: if b is Player: _player_near = false)
	_set_lit(GameState.last_tintero == room_id)


func _process(delta: float) -> void:
	_t += delta
	_prompt.modulate.a = move_toward(_prompt.modulate.a, 1.0 if _player_near else 0.0, delta * 4.0)
	if _flame.visible:
		_flame.scale = Vector2(1.0 + sin(_t * 9.0) * 0.08, 1.0 + sin(_t * 13.0) * 0.12)
		_light.energy = 1.1 + sin(_t * 11.0) * 0.12


func _physics_process(_delta: float) -> void:
	if _player_near and Input.is_action_just_pressed(&"interact"):
		var p := get_tree().get_first_node_in_group(&"player") as Player
		if p and p.is_on_floor() and not p.is_dead():
			rest(p)


func rest(player: Player) -> void:
	player.health.reset()
	player.ink.reset()
	GameState.last_tintero = room_id
	GameState.last_room = room_id
	SaveManager.save(0)
	_set_lit(true)
	for e in get_tree().get_nodes_in_group(&"enemies"):
		if e is EnemyBase and is_ancestor_of_room(e):
			(e as EnemyBase).reset_enemy()
	EventBus.rested_at_tintero.emit(room_id)
	rested.emit()


func is_ancestor_of_room(n: Node) -> bool:
	return get_parent().is_ancestor_of(n)


func _set_lit(lit: bool) -> void:
	_flame.visible = lit
	_light.enabled = lit


func _build_visual() -> void:
	var c := Color(0.06, 0.06, 0.08)
	EnemyBody.poly(self, [Vector2(-40, 0), Vector2(40, 0), Vector2(30, -20), Vector2(-30, -20)], c)
	EnemyBody.poly(self, [Vector2(-5, -20), Vector2(5, -20), Vector2(4, -150), Vector2(-4, -150)], c)
	EnemyBody.poly(self, [Vector2(-4, -150), Vector2(30, -170), Vector2(34, -164), Vector2(4, -142)], c)
	# Farol colgante con forma de tintero.
	EnemyBody.poly(self, [Vector2(18, -164), Vector2(42, -164), Vector2(48, -140), Vector2(40, -110),
			Vector2(20, -110), Vector2(12, -140)], c)
	_flame = EnemyBody.poly(self, [Vector2(30, -150), Vector2(36, -132), Vector2(30, -120), Vector2(24, -132)],
			Color(2.6, 1.6, 0.7))
	_light = PointLight2D.new()
	_light.texture = DropTexture.soft()
	_light.texture_scale = 7.0
	_light.color = Color(1.0, 0.75, 0.45)
	_light.position = Vector2(30, -134)
	add_child(_light)
