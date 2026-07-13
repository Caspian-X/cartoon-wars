@tool
extends McpTestSuite

const LEVELS: Array[LevelDefinition] = [preload("res://data/levels/the_beginning.tres")]


func suite_name() -> String:
	return "game_states"


func test_menu_level_select_playing_and_over_presentations() -> void:
	var hud := _create_hud()
	if hud == null:
		return
	var menu: Control = hud.get("_menu_overlay")
	var level_select: Control = hud.get("_level_select_overlay")
	var result: Control = hud.get("_result_overlay")
	var tray: Control = hud.get("_bottom_tray")

	hud.show_menu()
	assert_true(menu.visible)
	assert_false(tray.visible)
	hud.show_level_select(LEVELS)
	assert_true(level_select.visible)
	assert_false(menu.visible)
	hud.hide_level_select()
	hud.set_gameplay_visible(true)
	assert_true(tray.visible)
	hud.show_result(true)
	assert_true(result.visible)
	assert_false(tray.visible)


func test_game_controller_declares_required_states_and_transitions() -> void:
	var script := load("res://features/game/game.gd") as Script
	var constants := script.get_script_constant_map()
	assert_eq(constants["STATE_MENU"], "menu")
	assert_eq(constants["STATE_LEVEL_SELECT"], "level_select")
	assert_eq(constants["STATE_PLAYING"], "playing")
	assert_eq(constants["STATE_OVER"], "over")
	var methods: Array[String] = []
	for method in script.get_script_method_list():
		methods.append(method.name)
	for required in ["_on_level_select_requested", "_on_level_selected", "start_game", "_show_menu"]:
		assert_contains(methods, required)


func _create_hud() -> HUD:
	var root := EditorInterface.get_edited_scene_root()
	assert_true(root != null, "The main scene must be open")
	if root == null:
		return null
	var hud := track(preload("res://features/ui/hud.gd").new()) as HUD
	hud.name = "_McpTestGameStatesHUD"
	root.add_child(hud)
	return hud
