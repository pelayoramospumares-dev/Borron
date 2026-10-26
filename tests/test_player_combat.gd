extends GutTest

const PlayerScene := preload("res://player/player.tscn")
const RoomScript := preload("res://tests/scenes/test_room.gd")

var room: Node2D
var player: Player


func before_each() -> void:
	PlayerTestHelpers.release_all()
	HitStop.enabled = false
	GameState.reset()
	room = Node2D.new()
	room.set_script(RoomScript)
	add_child_autofree(room)
	player = PlayerScene.instantiate()
	player.position = Vector2(-800, -48)
	room.add_child(player)
	await wait_physics_frames(6)


func after_each() -> void:
	PlayerTestHelpers.release_all()
	HitStop.enabled = true


func test_attack_damages_dummy() -> void:
	var dummy := CombatTestHelpers.make_dummy(room, player.position + Vector2(70, 0))
	await wait_physics_frames(2)
	Input.action_press("attack")
	await wait_physics_frames(30)
	assert_eq(CombatTestHelpers.health_of(dummy).hp, 990.0)


func test_attack_hits_once_per_swing() -> void:
	var dummy := CombatTestHelpers.make_dummy(room, player.position + Vector2(70, 0))
	await wait_physics_frames(2)
	Input.action_press("attack")
	await wait_physics_frames(20)
	assert_eq(CombatTestHelpers.health_of(dummy).hp, 990.0)


func test_hit_gains_ink() -> void:
	CombatTestHelpers.make_dummy(room, player.position + Vector2(70, 0))
	await wait_physics_frames(2)
	Input.action_press("attack")
	await wait_physics_frames(30)
	assert_almost_eq(player.ink.ink, 12.0, 0.01)


func test_pogo_bounces() -> void:
	player.global_position = Vector2(-800, -400)
	player.velocity = Vector2.ZERO
	CombatTestHelpers.make_dummy(room, Vector2(-800, -300), Vector2(200, 60))
	await wait_physics_frames(1)
	Input.action_press("move_down")
	Input.action_press("attack")
	var bounced := false
	for i in 30:
		await wait_physics_frames(1)
		if player.velocity.y < -500.0:
			bounced = true
	assert_true(bounced)


func test_heal_full() -> void:
	player.ink.ink = 100
	player.health.hp = 50
	Input.action_press("heal")
	await wait_physics_frames(roundi(0.8 * 120) + 6)
	Input.action_release("heal")
	await wait_physics_frames(2)
	assert_eq(player.health.hp, 75.0)
	assert_almost_eq(player.ink.ink, 67.0, 0.01)


func test_heal_interrupted() -> void:
	player.ink.ink = 100
	player.health.hp = 50
	Input.action_press("heal")
	await wait_physics_frames(48)
	CombatTestHelpers.make_enemy_hitbox(room, player.position, 20, Vector2(80, 80))
	await wait_physics_frames(60)
	assert_eq(player.ink.ink, 100.0)
	assert_lt(player.health.hp, 50.0)


func test_invulnerable_after_hit() -> void:
	CombatTestHelpers.make_enemy_hitbox(room, player.position, 20)
	await wait_physics_frames(60)
	assert_eq(player.health.hp, 80.0)
	await wait_physics_frames(84)
	assert_eq(player.health.hp, 60.0)


func test_respawn_clears_overflow() -> void:
	player.ink.ink = 100
	player.ink.instability = 100
	await wait_physics_frames(2)
	assert_eq(player.ink.state, InkMeter.State.OVERFLOW)
	player.health.take_damage(1000)
	await wait_physics_frames(2)
	assert_eq(player.sm.current_name(), &"dead")
	player.respawn(Vector2(-800, -48))
	await wait_physics_frames(2)
	assert_eq(player.ink.state, InkMeter.State.NORMAL)
	assert_eq(player.ink.instability, 0.0)
	assert_eq(player.health.hp, player.health.max_hp)
	assert_ne(player.sm.current_name(), &"dead")


func test_respawn_clears_vulnerable() -> void:
	player.ink.ink = 100
	player.ink.instability = 100
	await wait_physics_frames(2)
	player.ink.tick(10.0)
	assert_eq(player.ink.state, InkMeter.State.VULNERABLE)
	player.health.take_damage(1000)
	player.respawn(Vector2(-800, -48))
	await wait_physics_frames(2)
	assert_eq(player.ink.state, InkMeter.State.NORMAL)
	assert_eq(player.health.damage_taken_mult, 1.0)


func test_death_emits_event() -> void:
	watch_signals(EventBus)
	player.health.take_damage(1000)
	await wait_physics_frames(2)
	assert_signal_emitted(EventBus, "player_died")


func test_max_hp_from_mods() -> void:
	GameState.recuerdos = 10
	SkillTree.load_all().purchase(&"forma_1")
	player.refresh_mods()
	assert_eq(player.health.max_hp, 120.0)
