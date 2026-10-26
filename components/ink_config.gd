class_name InkConfig
extends Resource
## Valores ajustables de Tinta, Inestabilidad y Desborde (spec §4.2).

@export var max_ink: float = 100.0
@export var ink_per_hit: float = 12.0
@export var heal_cost: float = 33.0
@export var heal_amount: float = 25.0
@export var heal_time: float = 0.8
@export var instability_threshold: float = 60.0
@export var instability_rise_per_sec: float = 10.0
@export var instability_decay_per_sec: float = 8.0
@export var spend_instability_reduction: float = 0.5
@export var overflow_duration: float = 6.0
@export var overflow_damage_mult: float = 1.75
@export var overflow_speed_mult: float = 1.2
@export var vulnerable_duration: float = 3.0
@export var vulnerable_damage_taken_mult: float = 1.5
