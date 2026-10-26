class_name SkillNode
extends Resource
## Un nodo del árbol de habilidades.

@export var id: StringName
@export_enum("forma", "marea", "voracidad") var branch: String = "forma"
@export var name_key: String
@export var desc_key: String
@export var cost: int = 1
@export var requires: Array[StringName] = []
## Habilidad llave necesaria (vacío si no hace falta).
@export var requires_ability: StringName = &""
## Clave de StatMods -> valor.
@export var mods: Dictionary = {}
