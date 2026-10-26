class_name BossArena
extends Node2D
## Arena de jefe: al entrar el jugador cierra las puertas y aparece el jefe.
## Al vencerlo emite boss_defeated, da Recuerdos y abre. Si el jugador muere,
## la arena se reinicia.

signal boss_started(boss: EnemyBase, title_key: String)
signal boss_finished()

const REWARD := 8

@export var boss_id: StringName = &"scribe"
@export var title_key: String = "BOSS_SCRIBE"
@export var boss_scene: PackedScene
@export var boss_spawn: Vector2
@export var trigger_rect: Rect2
@export var door_rects: Array[Rect2] = []

var locked: bool = false
var boss: EnemyBase
var _trigger: Area2D
var _doors: Array[StaticBody2D] = []


func _ready() -> void:
	_trigger = Area2D.new()
	_trigger.collision_layer = 0
	_trigger.collision_mask = 2
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = trigger_rect.size
	cs.shape = r
	cs.position = trigger_rect.get_center()
	_trigger.add_child(cs)
	add_child(_trigger)
	_trigger.body_entered.connect(_on_body_entered)
	for rect in door_rects:
		var door := StaticBody2D.new()
		door.collision_layer = 1
		var dcs := CollisionShape2D.new()
		var dr := RectangleShape2D.new()
		dr.size = rect.size
		dcs.shape = dr
		dcs.disabled = true
		door.position = rect.get_center()
		door.add_child(dcs)
		var vis := Polygon2D.new()
		var h := rect.size * 0.5
		vis.polygon = PackedVector2Array([-h, Vector2(h.x, -h.y), h, Vector2(-h.x, h.y)])
		vis.color = Color(0.03, 0.03, 0.05)
		vis.visible = false
		door.add_child(vis)
		add_child(door)
		_doors.append(door)
	EventBus.player_died.connect(_on_player_died)


func is_defeated() -> bool:
	return GameState.bosses_defeated.has(boss_id)


func _on_body_entered(body: Node) -> void:
	if locked or is_defeated() or not (body is Player):
		return
	_set_locked(true)
	boss = boss_scene.instantiate()
	boss.position = boss_spawn
	# Diferido: no se pueden añadir áreas durante la resolución de colisiones.
	add_child.call_deferred(boss)
	boss.ready.connect(func() -> void:
		boss.health.died.connect(_on_boss_died)
		boss_started.emit(boss, title_key), CONNECT_ONE_SHOT)


func _on_boss_died() -> void:
	GameState.bosses_defeated.append(boss_id)
	GameState.add_recuerdos(REWARD)
	EventBus.boss_defeated.emit(boss_id)
	_set_locked(false)
	boss_finished.emit()
	var b := boss
	boss = null
	b.queue_free()


func _on_player_died() -> void:
	if not locked:
		return
	_set_locked(false)
	if boss:
		boss.queue_free()
		boss = null
	boss_finished.emit()


func _set_locked(v: bool) -> void:
	locked = v
	for door in _doors:
		(door.get_child(0) as CollisionShape2D).set_deferred(&"disabled", not v)
		(door.get_child(1) as CanvasItem).visible = v
