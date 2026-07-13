@tool
extends McpTestSuite

const PLAYER_UNITS: Array[UnitDefinition] = [
	preload("res://data/units/spearman.tres"), preload("res://data/units/bowman.tres"),
	preload("res://data/units/wizard.tres"), preload("res://data/units/broadsword.tres"),
	preload("res://data/units/soldier_flamethrower.tres"),
]
const ENEMY_UNITS: Array[UnitDefinition] = [
	preload("res://data/units/golem.tres"), preload("res://data/units/skeleton.tres"),
	preload("res://data/units/imp.tres"),
]
const REQUIRED_ANIMATIONS := ["Idle", "Walk", "Attack", "Death"]


func suite_name() -> String:
	return "ui_feedback"


func test_playing_hud_has_five_centered_deployment_tiles() -> void:
	var root := EditorInterface.get_edited_scene_root()
	var hud := track(preload("res://features/ui/hud.gd").new()) as HUD
	hud.name = "_McpTestHUD"
	root.add_child(hud)
	hud.set_troop_data(PLAYER_UNITS)
	var buttons: Array = hud.get("_troop_buttons")
	var tray: Control = hud.get("_bottom_tray")
	assert_eq(buttons.size(), 5)
	assert_true(tray.position.y > Battlefield.GROUND_Y)
	var first := buttons[0].get_parent() as Control
	var last := buttons[4].get_parent() as Control
	assert_true(absf((first.position.x + last.position.x + last.size.x) * 0.5 - tray.size.x * 0.5) < 1.0)


func test_all_current_units_have_models_and_combat_animations() -> void:
	var root := EditorInterface.get_edited_scene_root()
	for definition in PLAYER_UNITS + ENEMY_UNITS:
		assert_eq(definition.presentation, "model_viewport", "%s presentation" % definition.id)
		assert_true(definition.presentation_scene != null, "%s wrapper" % definition.id)
		var path := "res://assets/models/characters/%s.glb" % definition.id
		var scene := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		assert_true(scene != null, "%s GLB" % definition.id)
		var model := track(scene.instantiate()) as Node
		model.name = "_McpTest%sModel" % definition.id
		root.add_child(model)
		var players := model.find_children("*", "AnimationPlayer", true, false)
		assert_true(not players.is_empty(), "%s AnimationPlayer" % definition.id)
		var names: Array[String] = []
		for imported_name in (players[0] as AnimationPlayer).get_animation_list():
			names.append(String(imported_name))
		for required in REQUIRED_ANIMATIONS:
			assert_contains(names, required, "%s is missing %s" % [definition.id, required])
