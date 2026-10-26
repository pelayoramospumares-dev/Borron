extends Node
## Señales globales para desacoplar sistemas.

@warning_ignore_start("unused_signal")
signal player_died()
signal player_respawned()
signal enemy_killed(enemy: Node)
signal boss_defeated(boss_id: StringName)
signal recuerdos_changed(total: int)
signal ability_unlocked(id: StringName)
signal rested_at_tintero(tintero_id: StringName)
signal hit_landed(position: Vector2, strength: float)
@warning_ignore_restore("unused_signal")
