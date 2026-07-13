@tool
extends McpTestSuite

const EXPECTED_UNITS := {
	"spearman": [2, 35.0, 6.0, 0.9, 0.018, 0.11, "melee"],
	"bowman": [4, 22.0, 9.0, 1.1, 0.16, 0.09, "bow"],
	"wizard": [6, 30.0, 12.0, 1.3, 0.155, 0.085, "magic"],
	"broadsword": [8, 120.0, 18.0, 1.4, 0.024, 0.05, "melee"],
	"soldier_flamethrower": [5, 48.0, 14.0, 0.65, 0.10, 0.075, "flame"],
	"golem": [4, 80.0, 10.0, 1.2, 0.022, 0.06, "melee"],
	"skeleton": [3, 18.0, 7.0, 1.0, 0.14, 0.10, "bow"],
	"imp": [5, 20.0, 10.0, 1.0, 0.14, 0.12, "magic"],
}


func suite_name() -> String:
	return "entities_data_model"


func test_unit_resources_match_gamespec_tables() -> void:
	for id: String in EXPECTED_UNITS:
		var unit := load("res://data/units/%s.tres" % id) as UnitDefinition
		var expected: Array = EXPECTED_UNITS[id]
		assert_true(unit != null, "%s resource must load" % id)
		assert_eq(unit.cost, expected[0], "%s cost" % id)
		assert_eq(unit.max_hp, expected[1], "%s HP" % id)
		assert_eq(unit.damage, expected[2], "%s damage" % id)
		assert_eq(unit.attack_interval, expected[3], "%s attack interval" % id)
		assert_eq(unit.attack_range, expected[4], "%s range" % id)
		assert_eq(unit.speed, expected[5], "%s speed" % id)
		assert_eq(unit.weapon, expected[6], "%s weapon" % id)


func test_level_one_roster_matches_gamespec() -> void:
	var level := load("res://data/levels/the_beginning.tres") as LevelDefinition
	assert_eq(level.id, 1)
	assert_eq(level.display_name, "The Beginning")
	var roster: Array[String] = []
	for unit in level.enemy_units:
		roster.append(String(unit.id))
	assert_eq(roster, ["golem", "skeleton", "imp"])
