@tool
extends McpTestSuite

var combat: CombatSystem


func suite_name() -> String:
	return "rules"


func setup() -> void:
	var root := EditorInterface.get_edited_scene_root()
	combat = track(CombatSystem.new()) as CombatSystem
	combat.name = "_McpTestCombat"
	root.add_child(combat)
	var troops := track(Node2D.new()) as Node2D
	var projectiles := track(Node2D.new()) as Node2D
	var particles := track(ParticleField.new()) as ParticleField
	root.add_child(troops)
	root.add_child(projectiles)
	root.add_child(particles)
	combat.setup(troops, projectiles, particles)


func test_spawning_and_movement_follow_lane_rules() -> void:
	var definition := _definition("walker", "melee", 20.0, 4.0, 0.1, 0.05)
	var player := combat.spawn_troop("player", definition)
	var enemy := combat.spawn_troop("enemy", definition)
	assert_eq(player.frac, 0.0, "R3 player spawn")
	assert_eq(enemy.frac, 1.0, "R3 enemy spawn")
	combat.update(1.0, 1.0)
	assert_eq(player.frac, 0.1, "R5 player movement")
	assert_eq(enemy.frac, 0.9, "R5 enemy movement")


func test_melee_and_ranged_attacks_apply_damage_at_the_correct_time() -> void:
	var melee := combat.spawn_troop("player", _definition("melee", "melee", 20.0, 6.0, 0.0, 0.1))
	var target := combat.spawn_troop("enemy", _definition("target", "melee", 30.0, 1.0, 0.0, 0.1))
	melee.frac = 0.5
	target.frac = 0.55
	combat.update(0.01, 0.01)
	assert_eq(target.hp, 24.0, "R8 melee damage is immediate")

	combat.reset()
	var archer := combat.spawn_troop("player", _definition("archer", "bow", 20.0, 9.0, 0.0, 0.2))
	target = combat.spawn_troop("enemy", _definition("target", "melee", 30.0, 1.0, 0.0, 0.1))
	archer.frac = 0.5
	target.frac = 0.6
	combat.update(0.01, 0.01)
	assert_eq(target.hp, 30.0, "R9 ranged damage waits for arrival")
	assert_eq(combat.projectiles.size(), 1)
	combat._update_projectiles(1.0)
	assert_eq(target.hp, 21.0, "R9 ranged damage applies on arrival")


func test_flamethrower_damages_only_targets_inside_aoe() -> void:
	var flamer_def := _definition("flamer", "flame", 30.0, 14.0, 0.0, 0.12)
	flamer_def.aoe_range = 0.065
	var flamer := combat.spawn_troop("player", flamer_def)
	var primary := combat.spawn_troop("enemy", _definition("primary", "melee", 30.0, 1.0, 0.0, 0.1))
	var nearby := combat.spawn_troop("enemy", _definition("nearby", "melee", 30.0, 1.0, 0.0, 0.1))
	var far := combat.spawn_troop("enemy", _definition("far", "melee", 30.0, 1.0, 0.0, 0.1))
	flamer.frac = 0.5
	primary.frac = 0.55
	nearby.frac = 0.60
	far.frac = 0.7
	combat.update(0.01, 0.01)
	assert_eq(primary.hp, 16.0, "R11a primary damage")
	assert_eq(nearby.hp, 16.0, "R11a nearby AoE damage")
	assert_eq(far.hp, 30.0, "R11a excludes distant targets")


func test_crossbow_targeting_respects_player_range() -> void:
	var definition := _definition("target", "melee", 20.0, 1.0, 0.0, 0.1)
	var inside := combat.spawn_troop("enemy", definition)
	inside.frac = 0.7
	var outside := combat.spawn_troop("enemy", definition)
	outside.frac = 0.8
	assert_eq(combat.nearest_crossbow_target("player"), inside, "R14 target range")
	inside.frac = 0.76
	assert_eq(combat.nearest_crossbow_target("player"), null, "R14 excludes troops beyond 75%")


func _definition(id: String, weapon: String, hp: float, damage: float, speed: float, attack_range: float) -> UnitDefinition:
	var definition := UnitDefinition.new()
	definition.id = id
	definition.weapon = weapon
	definition.max_hp = hp
	definition.damage = damage
	definition.speed = speed
	definition.attack_range = attack_range
	definition.attack_interval = 1.0
	return definition
