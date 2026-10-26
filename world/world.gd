class_name World
extends Node2D
## Mundo: jugador persistente, cámara, efectos y la sala actual. Cambia de sala
## con un fundido, reaparece al jugador en el último Tintero y suelta Recuerdos.

const PlayerScene := preload("res://player/player.tscn")
const RESPAWN_DELAY := 1.2
const DROP_FADE_IN := 0.2

@export var start_room: StringName = &"r01"
@export var start_entry: StringName = &"start"
@export var fade_time: float = 0.22

var player: Player
var camera: GameCamera
var vfx: VfxSpawner
var room: Room
var drop_chance_override: float = -1.0
var _fade: ColorRect
var _sky: ColorRect
var _sky_mat: ShaderMaterial
var _transitioning: bool = false
var _room_holder: Node2D


func _ready() -> void:
	add_to_group(&"world")
	add_child(GameEnvironment.create())
	_build_sky()
	_room_holder = Node2D.new()
	_room_holder.name = "Rooms"
	add_child(_room_holder)
	vfx = VfxSpawner.new()
	vfx.z_index = 6
	add_child(vfx)
	player = PlayerScene.instantiate()
	player.z_index = 2
	add_child(player)
	camera = GameCamera.new()
	add_child(camera)
	camera.make_current()
	camera.target = player
	vfx.camera = camera
	vfx.bind_player(player)
	_build_fade()
	add_child(FpsCounter.new())
	EventBus.player_died.connect(_on_player_died)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	_load_room(start_room)
	_place_player(start_entry)


## Cambia a otra sala manteniendo la velocidad y el estado del jugador.
func change_room(room_id: StringName, entry_id: StringName) -> void:
	if _transitioning:
		return
	_transitioning = true
	await _fade_to(1.0)
	var vel := player.velocity
	_load_room(room_id)
	_place_player(entry_id)
	player.velocity = vel
	await _fade_to(0.0)
	_transitioning = false


func _load_room(room_id: StringName) -> void:
	if room:
		_room_holder.remove_child(room)
		room.queue_free()
	var scene: PackedScene = load("res://world/zone1/%s.tscn" % room_id)
	room = scene.instantiate()
	_room_holder.add_child(room)
	GameState.last_room = room_id
	camera.set_room_limits(room.bounds)
	_sky_mat.set_shader_parameter(&"top", room.sky_top)
	_sky_mat.set_shader_parameter(&"bottom", room.sky_bottom)
	for arena in room.find_children("*", "BossArena", true, false):
		(arena as BossArena).boss_started.connect(func(b: EnemyBase, _k: String) -> void:
			camera.shake(10.0, 0.5)
			if b is Scribe:
				(b as Scribe).roared.connect(func() -> void: camera.shake(18.0, 0.9)))


func _place_player(entry_id: StringName) -> void:
	player.global_position = room.get_entry(entry_id)
	player.reset_physics_interpolation()
	camera.snap_to_target()


func _on_player_died() -> void:
	await get_tree().create_timer(RESPAWN_DELAY, false).timeout
	await _fade_to(1.0)
	var target_room := GameState.last_tintero if GameState.last_tintero != &"" else start_room
	_load_room(target_room)
	var entry_id: StringName = &"tintero" if room.has_entry(&"tintero") else start_entry
	player.respawn(room.get_entry(entry_id))
	camera.snap_to_target()
	await _fade_to(0.0)


func _on_enemy_killed(enemy: Node) -> void:
	var e := enemy as Node2D
	if e == null or room == null:
		return
	var chance := drop_chance_override
	if chance < 0.0:
		chance = (enemy as EnemyBase).stats.recuerdo_drop_chance if enemy is EnemyBase else 0.0
	if randf() < chance:
		var r := Recuerdo.new()
		r.value = 1
		room.add_actor.call_deferred(r)
		r.position = e.global_position + Vector2(0, -20)


func _fade_to(alpha: float) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, ^"color:a", alpha, fade_time)
	await tw.finished


func _build_fade() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	_fade = ColorRect.new()
	_fade.color = Color(0.01, 0.01, 0.02, 0.0)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	add_child(layer)


func _build_sky() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -100
	_sky = ColorRect.new()
	_sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sky_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = """shader_type canvas_item;
uniform vec4 top : source_color = vec4(0.66, 0.68, 0.72, 1.0);
uniform vec4 bottom : source_color = vec4(0.43, 0.44, 0.49, 1.0);
void fragment() { COLOR = mix(top, bottom, smoothstep(0.0, 1.0, UV.y)); }
"""
	_sky_mat.shader = sh
	_sky.material = _sky_mat
	layer.add_child(_sky)
	add_child(layer)
