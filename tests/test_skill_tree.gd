extends GutTest

var tree: SkillTree


func before_each() -> void:
	GameState.reset()
	tree = SkillTree.load_all()


func after_each() -> void:
	GameState.reset()


func test_purchase_deducts() -> void:
	GameState.recuerdos = 5
	assert_true(tree.purchase(&"forma_1"))
	assert_eq(GameState.recuerdos, 3)
	assert_has(GameState.purchased_skills, &"forma_1")


func test_reject_insufficient() -> void:
	GameState.recuerdos = 1
	assert_false(tree.purchase(&"forma_1"))
	assert_eq(GameState.recuerdos, 1)


func test_reject_missing_prereq() -> void:
	GameState.recuerdos = 10
	assert_false(tree.purchase(&"forma_2"))
	assert_eq(GameState.recuerdos, 10)


func test_reject_already_owned() -> void:
	GameState.recuerdos = 10
	tree.purchase(&"forma_1")
	assert_false(tree.purchase(&"forma_1"))
	assert_eq(GameState.recuerdos, 8)


func test_reject_missing_ability() -> void:
	GameState.recuerdos = 10
	tree.purchase(&"marea_1")
	assert_false(tree.purchase(&"marea_2"))
	GameState.unlock_ability(&"puddle")
	assert_true(tree.purchase(&"marea_2"))


func test_reject_unknown() -> void:
	GameState.recuerdos = 10
	assert_false(tree.purchase(&"nope"))


func test_mods_combine() -> void:
	GameState.recuerdos = 10
	tree.purchase(&"forma_1")
	tree.purchase(&"voracidad_1")
	var m := tree.compute_mods()
	assert_eq(m.max_hp_bonus, 20.0)
	assert_almost_eq(m.damage_mult, 1.1, 0.001)
	assert_almost_eq(m.ink_gain_mult, 1.25, 0.001)
	assert_eq(m.dash_distance_mult, 1.0)


func test_all_nine_nodes_load() -> void:
	assert_eq(tree.nodes.size(), 9)
	var total := 0
	for n in tree.nodes:
		total += n.cost
	assert_eq(total, 27)
