class_name EnemyStats
extends Resource
## Valores ajustables de un tipo de enemigo.

@export var max_hp: float = 30.0
@export var contact_damage: float = 20.0
@export var move_speed: float = 140.0
@export_range(0.0, 1.0) var recuerdo_drop_chance: float = 0.1
@export var aggro_range: float = 420.0
