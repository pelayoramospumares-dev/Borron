extends GutTest

const RoomScript := preload("res://tests/scenes/test_room.gd")
const CrawlerScene := preload("res://enemies/crawler/crawler.tscn")
const FlyerScene := preload("res://enemies/flyer/flyer.tscn")
const SpitterScene := preload("res://enemies/spitter/spitter.tscn")

var room: Node2D


func before_each() -> void:
	HitStop.enabled = false
	room = Node2D.new()
	room.set_script(RoomScript)
	add_child_autofree(room)


func after_each() -> void:
	HitStop.enabled = true


## Objetivo falso que los enemigos persiguen (grupo "player").
func _fake_player(pos: Vector2) -> Node2D:
	var p := Node2D.new()
	p.position = pos
	p.add_to_group(&"player")
	room.add_child(p)
	return p


func _hit(enemy: EnemyBase, damage: float) -> void:
	var hb := Hitbox.new()
	hb.damage = damage
	enemy.receive_hit(hb, Vector2.RIGHT)
	hb.free()


func test_crawler_turns_at_ledge() -> void:
	room.add_ledge()
	var c: EnemyBase = CrawlerScene.instantiate()
	c.position = Vector2(-200, -330)
	room.add_child(c)
	var min_x := 0.0
	var max_x := -400.0
	for i in 600:
		await wait_physics_frames(1)
		min_x = minf(min_x, c.global_position.x)
		max_x = maxf(max_x, c.global_position.x)
	assert_gt(c.global_position.y, -400.0, "sigue sobre la plataforma")
	assert_lt(c.global_position.y, -300.0, "no se ha caído")
	assert_lt(min_x, -300.0)
	assert_gt(max_x, -100.0)


func test_crawler_dies_after_three_hits() -> void:
	var c: EnemyBase = CrawlerScene.instantiate()
	c.position = Vector2(-800, -40)
	room.add_child(c)
	await wait_physics_frames(2)
	watch_signals(EventBus)
	_hit(c, 10)
	_hit(c, 10)
	assert_false(c.health.is_dead())
	_hit(c, 10)
	assert_true(c.health.is_dead())
	assert_signal_emitted(EventBus, "enemy_killed")


func test_flyer_telegraphs_before_dive() -> void:
	var f: EnemyBase = FlyerScene.instantiate()
	f.position = Vector2(-800, -400)
	room.add_child(f)
	await wait_physics_frames(2)
	_fake_player(Vector2(-700, -48))
	await wait_physics_frames(int(0.3 * 120))
	assert_eq(f.get(&"state"), &"telegraph")
	await wait_physics_frames(int(0.2 * 120))
	assert_eq(f.get(&"state"), &"dive")


func test_spitter_fires_on_interval() -> void:
	var s: EnemyBase = SpitterScene.instantiate()
	s.position = Vector2(-800, -40)
	room.add_child(s)
	_fake_player(Vector2(-300, -48))
	await wait_physics_frames(int(2.8 * 120))
	assert_eq(s.get(&"shots_fired"), 1)


func test_spitter_ignores_far_player() -> void:
	var s: EnemyBase = SpitterScene.instantiate()
	s.position = Vector2(-1000, -40)
	room.add_child(s)
	_fake_player(Vector2(-100, -48))
	await wait_physics_frames(int(2.8 * 120))
	assert_eq(s.get(&"shots_fired"), 0)


func test_reset_restores_enemy() -> void:
	var c: EnemyBase = CrawlerScene.instantiate()
	c.position = Vector2(-800, -40)
	room.add_child(c)
	await wait_physics_frames(60)
	_hit(c, 10)
	c.reset_enemy()
	assert_eq(c.global_position, Vector2(-800, -40))
	assert_eq(c.health.hp, c.stats.max_hp)


func test_dead_enemy_is_hidden_until_reset() -> void:
	var c: EnemyBase = CrawlerScene.instantiate()
	c.position = Vector2(-800, -40)
	room.add_child(c)
	await wait_physics_frames(2)
	for i in 3:
		_hit(c, 10)
	await wait_physics_frames(2)
	assert_false(c.visible)
	assert_false(c.contact_hitbox.monitorable)
	c.reset_enemy()
	assert_true(c.visible)
