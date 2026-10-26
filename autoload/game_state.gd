extends Node
## Progreso de la partida actual. Se serializa con SaveManager.

var recuerdos: int = 0
var abilities: Array[StringName] = []
var purchased_skills: Array[StringName] = []
var bosses_defeated: Array[StringName] = []
var collected_pickups: Array[StringName] = []
var last_tintero: StringName = &""
var last_room: StringName = &""


func has_ability(id: StringName) -> bool:
	return abilities.has(id)


func unlock_ability(id: StringName) -> void:
	if has_ability(id):
		return
	abilities.append(id)
	EventBus.ability_unlocked.emit(id)


func add_recuerdos(n: int) -> void:
	recuerdos += n
	EventBus.recuerdos_changed.emit(recuerdos)


func to_dict() -> Dictionary:
	return {
		"recuerdos": recuerdos,
		"abilities": _to_strings(abilities),
		"purchased_skills": _to_strings(purchased_skills),
		"bosses_defeated": _to_strings(bosses_defeated),
		"collected_pickups": _to_strings(collected_pickups),
		"last_tintero": String(last_tintero),
		"last_room": String(last_room),
	}


func from_dict(d: Dictionary) -> void:
	reset()
	recuerdos = int(d.get("recuerdos", 0))
	abilities = _to_names(d.get("abilities", []))
	purchased_skills = _to_names(d.get("purchased_skills", []))
	bosses_defeated = _to_names(d.get("bosses_defeated", []))
	collected_pickups = _to_names(d.get("collected_pickups", []))
	last_tintero = StringName(str(d.get("last_tintero", "")))
	last_room = StringName(str(d.get("last_room", "")))


func reset() -> void:
	recuerdos = 0
	abilities = []
	purchased_skills = []
	bosses_defeated = []
	collected_pickups = []
	last_tintero = &""
	last_room = &""


func _to_strings(arr: Array[StringName]) -> Array[String]:
	var out: Array[String] = []
	for s in arr:
		out.append(String(s))
	return out


func _to_names(value: Variant) -> Array[StringName]:
	var out: Array[StringName] = []
	if value is Array:
		for s: Variant in value:
			out.append(StringName(str(s)))
	return out
