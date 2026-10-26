class_name SkillTree
extends RefCounted
## Árbol de habilidades: reglas de compra y cálculo de modificadores.

const NODE_IDS: Array[StringName] = [
	&"forma_1", &"forma_2", &"forma_3",
	&"marea_1", &"marea_2", &"marea_3",
	&"voracidad_1", &"voracidad_2", &"voracidad_3",
]

var nodes: Array[SkillNode] = []


func _init(node_list: Array[SkillNode] = []) -> void:
	nodes = node_list


static func load_all() -> SkillTree:
	var list: Array[SkillNode] = []
	for id in NODE_IDS:
		list.append(load("res://skills/nodes/%s.tres" % id) as SkillNode)
	return SkillTree.new(list)


func get_node_by_id(id: StringName) -> SkillNode:
	for n in nodes:
		if n.id == id:
			return n
	return null


func is_purchased(id: StringName) -> bool:
	return GameState.purchased_skills.has(id)


func can_purchase(id: StringName) -> bool:
	var n := get_node_by_id(id)
	if n == null or is_purchased(id) or GameState.recuerdos < n.cost:
		return false
	if n.requires_ability != &"" and not GameState.has_ability(n.requires_ability):
		return false
	for req in n.requires:
		if not is_purchased(req):
			return false
	return true


func purchase(id: StringName) -> bool:
	if not can_purchase(id):
		return false
	var n := get_node_by_id(id)
	GameState.recuerdos -= n.cost
	GameState.purchased_skills.append(id)
	EventBus.recuerdos_changed.emit(GameState.recuerdos)
	return true


func compute_mods() -> StatMods:
	var m := StatMods.new()
	for n in nodes:
		if is_purchased(n.id):
			for key: Variant in n.mods:
				m.apply(StringName(str(key)), n.mods[key])
	return m
