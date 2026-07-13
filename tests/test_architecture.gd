@tool
extends McpTestSuite


func suite_name() -> String:
	return "architecture"


func test_main_scene_explicitly_composes_required_systems() -> void:
	var main_scene := load("res://scenes/main.tscn") as PackedScene
	assert_true(main_scene != null)
	var game := track(main_scene.instantiate()) as Node
	for path in ["Battlefield", "PlayerBase", "EnemyBase", "Troops", "Projectiles", "Particles", "CombatSystem", "HUD"]:
		assert_true(game.has_node(path), "Main scene is missing %s" % path)


func test_game_references_exported_environment_assets() -> void:
	assert_true(ResourceLoader.exists("res://assets/models/environment/battlefield.glb"))
	assert_true(ResourceLoader.exists("res://assets/models/environment/tower.glb"))
	assert_false(ResourceLoader.exists("res://blender/battlefield.blend"), "Runtime must not reference Blender source files")
