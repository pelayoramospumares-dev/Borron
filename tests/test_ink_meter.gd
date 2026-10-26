extends GutTest

var cfg: InkConfig


func before_each() -> void:
	cfg = load("res://components/ink_config.tres")


func _make() -> InkMeter:
	return InkMeter.new(cfg)


func test_gain_clamps_to_max() -> void:
	var m := _make()
	m.gain(500)
	assert_eq(m.ink, 100.0)


func test_instability_rises_above_threshold() -> void:
	var m := _make()
	m.ink = 60
	m.tick(1.0)
	assert_almost_eq(m.instability, 10.0, 0.001)


func test_instability_decays_below_threshold() -> void:
	var m := _make()
	m.instability = 20
	m.tick(1.0)
	assert_almost_eq(m.instability, 12.0, 0.001)


func test_spend_reduces_instability() -> void:
	var m := _make()
	m.ink = 100
	m.instability = 50
	assert_true(m.try_spend(33))
	assert_almost_eq(m.instability, 33.5, 0.001)
	assert_almost_eq(m.ink, 67.0, 0.001)


func test_spend_fails_when_insufficient() -> void:
	var m := _make()
	m.ink = 10
	assert_false(m.try_spend(33))
	assert_eq(m.ink, 10.0)


func test_overflow_cycle() -> void:
	var m := _make()
	watch_signals(m)
	m.ink = 100
	m.instability = 99
	m.tick(0.2)
	assert_eq(m.state, InkMeter.State.OVERFLOW)
	assert_signal_emitted(m, "overflow_started")
	assert_eq(m.ink, 0.0)
	assert_almost_eq(m.damage_dealt_mult(), 1.75, 0.001)
	assert_almost_eq(m.speed_mult(), 1.2, 0.001)
	m.tick(6.0)
	assert_eq(m.state, InkMeter.State.VULNERABLE)
	assert_almost_eq(m.damage_taken_mult(), 1.5, 0.001)
	assert_eq(m.instability, 0.0)
	m.tick(3.0)
	assert_eq(m.state, InkMeter.State.NORMAL)
	assert_signal_emitted(m, "vulnerability_ended")


func test_no_gain_while_vulnerable() -> void:
	var m := _make()
	m.ink = 100
	m.instability = 100
	m.tick(0.01)
	m.tick(6.0)
	assert_eq(m.state, InkMeter.State.VULNERABLE)
	m.gain(12)
	assert_eq(m.ink, 0.0)


func test_overflow_bonus_extends_duration() -> void:
	var m := _make()
	m.overflow_duration_bonus = 3.0
	m.ink = 100
	m.instability = 100
	m.tick(0.01)
	m.tick(8.0)
	assert_eq(m.state, InkMeter.State.OVERFLOW)


func test_instability_gain_mult_slows_rise() -> void:
	var m := _make()
	m.instability_gain_mult = 0.7
	m.ink = 80
	m.tick(1.0)
	assert_almost_eq(m.instability, 7.0, 0.001)


func test_normal_mults_scale_with_instability() -> void:
	var m := _make()
	m.instability = 50
	assert_almost_eq(m.damage_dealt_mult(), 1.25, 0.001)
	assert_almost_eq(m.damage_taken_mult(), 1.25, 0.001)
	assert_almost_eq(m.speed_mult(), 1.075, 0.001)


func test_reset() -> void:
	var m := _make()
	m.ink = 100
	m.instability = 100
	m.tick(0.01)
	m.reset()
	assert_eq(m.state, InkMeter.State.NORMAL)
	assert_eq(m.ink, 0.0)
	assert_eq(m.instability, 0.0)
