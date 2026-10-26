class_name StatMods
extends RefCounted
## Suma de los efectos de los nodos comprados. Valores neutros por defecto.

var max_hp_bonus: float = 0.0
var instability_gain_mult: float = 1.0
var heal_time_mult: float = 1.0
var dash_distance_mult: float = 1.0
var puddle_contact_damage: float = 0.0
var dash_refresh_on_hit: bool = false
var damage_mult: float = 1.0
var ink_gain_mult: float = 1.0
var overflow_duration_bonus: float = 0.0
var attack_range_mult: float = 1.0

const _MULTIPLICATIVE := [&"instability_gain_mult", &"heal_time_mult", &"dash_distance_mult",
		&"damage_mult", &"ink_gain_mult", &"attack_range_mult"]


func apply(key: StringName, value: Variant) -> void:
	if not key in self:
		push_warning("StatMods: clave desconocida %s" % key)
		return
	if value is bool:
		set(key, value)
	elif key in _MULTIPLICATIVE:
		set(key, float(get(key)) * float(value))
	else:
		set(key, float(get(key)) + float(value))
