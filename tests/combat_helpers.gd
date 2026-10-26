class_name CombatTestHelpers
## Utilidades de combate para pruebas.

## Diana con Hurtbox que recibe golpes del jugador (capa player_attack).
static func make_dummy(parent: Node, pos: Vector2, size := Vector2(60, 100)) -> Node2D:
	var dummy := Node2D.new()
	dummy.position = pos
	parent.add_child(dummy)
	var health := Health.new()
	health.max_hp = 1000
	health.reset()
	dummy.set_meta("health", health)
	var hb := Hurtbox.new()
	hb.collision_layer = 0
	hb.collision_mask = 8
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	cs.shape = rect
	hb.add_child(cs)
	dummy.add_child(hb)
	hb.owner = dummy
	hb.hit.connect(func(h: Hitbox) -> void: health.take_damage(h.damage))
	return dummy


## Hitbox enemigo (capa enemy_attack) que daña al jugador mientras lo toque.
static func make_enemy_hitbox(parent: Node, pos: Vector2, damage: float, size := Vector2(2000, 2000)) -> Hitbox:
	var hb := Hitbox.new()
	hb.damage = damage
	hb.collision_layer = 16
	hb.collision_mask = 0
	hb.position = pos
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	cs.shape = rect
	hb.add_child(cs)
	parent.add_child(hb)
	return hb


static func health_of(dummy: Node2D) -> Health:
	return dummy.get_meta("health")
