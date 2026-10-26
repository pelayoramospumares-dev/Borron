extends GutTest


func _make(max_hp: float = 100.0) -> Health:
	var h := Health.new()
	h.max_hp = max_hp
	h.reset()
	return h


func test_damage_with_mult() -> void:
	var h := _make()
	h.damage_taken_mult = 1.5
	assert_eq(h.take_damage(20), 30.0)
	assert_eq(h.hp, 70.0)


func test_heal_clamps() -> void:
	var h := _make()
	h.take_damage(10)
	h.heal(50)
	assert_eq(h.hp, 100.0)


func test_died_emits_once() -> void:
	var h := _make()
	watch_signals(h)
	h.take_damage(150)
	h.take_damage(150)
	assert_signal_emit_count(h, "died", 1)
	assert_true(h.is_dead())
	assert_eq(h.hp, 0.0)
