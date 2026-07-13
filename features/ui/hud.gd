class_name HUD
extends CanvasLayer

signal spawn_requested(type_idx: int)
signal aim_changed(delta: float)
signal start_requested()
signal menu_requested()
signal level_select_requested()
signal level_selected(level_id: int)

var _root: Control
var _player_bar_container: Control
var _player_fill: ColorRect
var _player_hp_label: Label
var _enemy_bar_container: Control
var _enemy_fill: ColorRect
var _enemy_hp_label: Label
var _mana_icon: ColorRect
var _mana_border: ColorRect
var _mana_fill: ColorRect
var _mana_label: Label
var _bottom_tray: Control
var _troop_buttons: Array = []
var _menu_overlay: Control
var _level_select_overlay: Control
var _result_overlay: Control
var _result_title: Label
var _result_sub: Label
var _aim_up: Button
var _aim_down: Button
var _troop_data: Array[UnitDefinition] = []

const VIEW_W := 1280.0
const VIEW_H := 720.0
const GROUND_Y := 634.0

const TROOP_TILE_IMAGES := {
	"spearman": "res://assets/sprites/spearman.png",
	"bowman": "res://assets/sprites/bowman.png",
	"wizard": "res://assets/sprites/wizard.png",
	"broadsword": "res://assets/sprites/broadsword.png",
	"soldier_flamethrower": "res://assets/sprites/flamer_portrait.svg",
}


func set_troop_data(arr: Array[UnitDefinition]) -> void:
	_troop_data = arr
	if _root and _bottom_tray:
		_root.remove_child(_bottom_tray)
		_bottom_tray.queue_free()
		_troop_buttons.clear()
		_build_bottom_tray()


func _ready() -> void:
	layer = 10
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	_build_top_hud()
	_build_bottom_tray()
	_build_aim_buttons()
	_build_menu_overlay()
	_build_level_select_overlay()
	_build_result_overlay()
	show_menu()


func _styled_panel(pos: Vector2, size: Vector2, bg: Color, border: Color, border_w: float = 2.0) -> Control:
	var c := Control.new()
	c.position = pos
	c.size = size
	var b := ColorRect.new()
	b.set_anchors_preset(Control.PRESET_FULL_RECT)
	b.color = border
	c.add_child(b)
	var fill := ColorRect.new()
	fill.position = Vector2(border_w, border_w)
	fill.size = Vector2(size.x - border_w * 2.0, size.y - border_w * 2.0)
	fill.color = bg
	c.add_child(fill)
	return c


func _build_top_hud() -> void:
	var bar_h: float = 16.0
	var bar_y: float = 12.0
	var bar_w: float = 380.0

	var p_border := _styled_panel(Vector2(14.0, bar_y), Vector2(bar_w + 4.0, bar_h + 4.0), Color(0.08, 0.08, 0.12, 0.7), Color(0.20, 0.25, 0.40, 0.5), 2.0)
	_root.add_child(p_border)
	_player_bar_container = p_border
	_player_fill = ColorRect.new()
	_player_fill.position = Vector2(2.0, 2.0)
	_player_fill.size = Vector2(bar_w, bar_h)
	_player_fill.color = Color(0.30, 0.65, 1.0)
	p_border.add_child(_player_fill)

	_player_hp_label = _make_label(p_border, Vector2(4.0, 0.0), bar_w, 12)
	_player_hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var e_border := _styled_panel(Vector2(VIEW_W - 14.0 - bar_w - 4.0, bar_y), Vector2(bar_w + 4.0, bar_h + 4.0), Color(0.08, 0.08, 0.12, 0.7), Color(0.40, 0.20, 0.20, 0.5), 2.0)
	_root.add_child(e_border)
	_enemy_bar_container = e_border
	_enemy_fill = ColorRect.new()
	_enemy_fill.position = Vector2(2.0, 2.0)
	_enemy_fill.size = Vector2(bar_w, bar_h)
	_enemy_fill.color = Color(1.0, 0.35, 0.28)
	e_border.add_child(_enemy_fill)

	_enemy_hp_label = _make_label(e_border, Vector2(4.0, 0.0), bar_w, 12)
	_enemy_hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_enemy_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func _make_label(parent: Control, pos: Vector2, w: float, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = Vector2(w, 18.0)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(l)
	return l


func _build_bottom_tray() -> void:
	var tray_y: float = GROUND_Y + 4.0
	var tray_h: float = VIEW_H - tray_y - 4.0

	_bottom_tray = _styled_panel(Vector2(10.0, tray_y), Vector2(VIEW_W - 20.0, tray_h), Color(0.06, 0.06, 0.10, 0.82), Color(0.15, 0.15, 0.22, 0.55), 2.0)
	_root.add_child(_bottom_tray)

	_mana_icon = ColorRect.new()
	_mana_icon.position = Vector2(12.0, 14.0)
	_mana_icon.size = Vector2(14.0, 14.0)
	_mana_icon.color = Color(0.50, 0.78, 1.0)
	_bottom_tray.add_child(_mana_icon)
	var mana_border := ColorRect.new()
	mana_border.position = Vector2(32.0, 10.0)
	mana_border.size = Vector2(154.0, 18.0)
	mana_border.color = Color(0.15, 0.18, 0.25, 0.6)
	_bottom_tray.add_child(mana_border)
	_mana_fill = ColorRect.new()
	_mana_fill.position = Vector2(34.0, 12.0)
	_mana_fill.size = Vector2(150.0, 14.0)
	_mana_fill.color = Color(0.40, 0.70, 1.0)
	_bottom_tray.add_child(_mana_fill)
	_mana_label = _make_label(_bottom_tray, Vector2(32.0, 26.0), 150.0, 10)

	var n: int = _troop_data.size()
	var bw: float = 68.0
	var gap: float = 8.0
	var total_w: float = n * bw + (n - 1) * gap
	var start_x: float = (VIEW_W - 20.0 - total_w) * 0.5

	var btn_colors := [
		Color(0.25, 0.45, 0.75),
		Color(0.20, 0.60, 0.30),
		Color(0.45, 0.25, 0.65),
		Color(0.65, 0.18, 0.18),
		Color(0.90, 0.38, 0.08),
	]

	for i in n:
		var d: UnitDefinition = _troop_data[i]
		var col: Color = btn_colors[i] if i < btn_colors.size() else Color(0.3, 0.3, 0.4)
		var btn_container := _styled_panel(
			Vector2(start_x + i * (bw + gap), 5.0),
			Vector2(bw, bw),
			Color(col.r * 0.12, col.g * 0.12, col.b * 0.12, 0.96),
			col,
			2.0
		)
		btn_container.clip_contents = true
		_bottom_tray.add_child(btn_container)

		var image := TextureRect.new()
		image.position = Vector2(4.0, 4.0)
		image.size = Vector2(bw - 8.0, bw - 8.0)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var image_path: String = String(TROOP_TILE_IMAGES.get(d.id, ""))
		if not image_path.is_empty():
			image.texture = load(image_path)
		btn_container.add_child(image)

		var shade := ColorRect.new()
		shade.position = Vector2(2.0, bw - 20.0)
		shade.size = Vector2(bw - 4.0, 18.0)
		shade.color = Color(0.02, 0.03, 0.07, 0.82)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn_container.add_child(shade)

		var key_label := _make_label(btn_container, Vector2(5.0, 3.0), 18.0, 15)
		key_label.text = str(i + 1)
		key_label.add_theme_color_override("font_color", Color.WHITE)
		key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var cost_label := _make_label(btn_container, Vector2(5.0, bw - 20.0), bw - 10.0, 15)
		cost_label.text = str(d.cost)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cost_label.add_theme_color_override("font_color", Color(0.35, 0.72, 1.0))
		cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var btn := Button.new()
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.tooltip_text = "%d: %s (%d mana)" % [i + 1, d.display_name, d.cost]
		btn.add_theme_stylebox_override("normal", _empty_sb())
		btn.add_theme_stylebox_override("pressed", _btn_sb(Color(0.25, 0.55, 0.9, 0.28), Color(0.45, 0.8, 1.0, 0.8)))
		btn.add_theme_stylebox_override("hover", _btn_sb(Color(0.3, 0.65, 1.0, 0.15), Color(0.5, 0.82, 1.0, 0.75)))
		btn.add_theme_stylebox_override("disabled", _btn_sb(Color(0.02, 0.02, 0.03, 0.62), Color(0.18, 0.18, 0.22, 0.9)))
		btn.pressed.connect(_on_troop_btn.bind(i))
		btn_container.add_child(btn)
		_troop_buttons.append(btn)


func _empty_sb() -> StyleBoxEmpty:
	var sb := StyleBoxEmpty.new()
	return sb


func _build_aim_buttons() -> void:
	var c := _styled_panel(Vector2(10.0, VIEW_H - 144.0), Vector2(46.0, 62.0), Color(0.06, 0.06, 0.10, 0.75), Color(0.15, 0.15, 0.22, 0.4), 1.5)
	_root.add_child(c)
	_aim_up = Button.new()
	_aim_up.position = Vector2(2.0, 2.0)
	_aim_up.size = Vector2(42.0, 26.0)
	_aim_up.text = "^"
	_aim_up.add_theme_font_size_override("font_size", 16)
	_aim_up.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	_aim_up.add_theme_stylebox_override("normal", _btn_sb(Color(0.20, 0.25, 0.35, 0.6), Color(0.30, 0.40, 0.55, 0.4)))
	_aim_up.add_theme_stylebox_override("pressed", _btn_sb(Color(0.30, 0.40, 0.55, 0.8), Color(0.40, 0.50, 0.65, 0.5)))
	_aim_up.add_theme_stylebox_override("hover", _btn_sb(Color(0.25, 0.32, 0.45, 0.7), Color(0.35, 0.45, 0.60, 0.5)))
	_aim_up.pressed.connect(func(): aim_changed.emit(-0.05))
	c.add_child(_aim_up)
	_aim_down = Button.new()
	_aim_down.position = Vector2(2.0, 31.0)
	_aim_down.size = Vector2(42.0, 26.0)
	_aim_down.text = "v"
	_aim_down.add_theme_font_size_override("font_size", 16)
	_aim_down.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	_aim_down.add_theme_stylebox_override("normal", _btn_sb(Color(0.20, 0.25, 0.35, 0.6), Color(0.30, 0.40, 0.55, 0.4)))
	_aim_down.add_theme_stylebox_override("pressed", _btn_sb(Color(0.30, 0.40, 0.55, 0.8), Color(0.40, 0.50, 0.65, 0.5)))
	_aim_down.add_theme_stylebox_override("hover", _btn_sb(Color(0.25, 0.32, 0.45, 0.7), Color(0.35, 0.45, 0.60, 0.5)))
	_aim_down.pressed.connect(func(): aim_changed.emit(0.05))
	c.add_child(_aim_down)


func _btn_sb(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_right = 3
	sb.corner_radius_bottom_left = 3
	return sb


func _build_menu_overlay() -> void:
	_menu_overlay = Control.new()
	_menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_menu_overlay)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.04, 0.08, 0.82)
	_menu_overlay.add_child(dim)

	var panel := _styled_panel(
		Vector2(VIEW_W * 0.5 - 240.0, VIEW_H * 0.5 - 160.0),
		Vector2(480.0, 320.0),
		Color(0.08, 0.08, 0.14, 0.92),
		Color(0.30, 0.30, 0.50, 0.4),
		2.0
	)
	panel.name = "MenuPanel"
	_menu_overlay.add_child(panel)

	var title := Label.new()
	title.text = "CARTOON WARS"
	title.position = Vector2(0.0, 30.0)
	title.size = Vector2(480.0, 60.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.90, 0.85, 0.65))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	panel.add_child(title)

	var div := ColorRect.new()
	div.position = Vector2(80.0, 100.0)
	div.size = Vector2(320.0, 1.0)
	div.color = Color(0.40, 0.35, 0.25, 0.3)
	panel.add_child(div)

	var sub := Label.new()
	sub.text = "Destroy the enemy base before yours falls!"
	sub.position = Vector2(0.0, 115.0)
	sub.size = Vector2(480.0, 30.0)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.70, 0.70, 0.80))
	panel.add_child(sub)

	var controls := Label.new()
	controls.text = "1-5 = Spawn troops   |   Up/Down = Aim crossbow   |   R = Restart"
	controls.position = Vector2(0.0, 145.0)
	controls.size = Vector2(480.0, 24.0)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 12)
	controls.add_theme_color_override("font_color", Color(0.50, 0.50, 0.65))
	panel.add_child(controls)

	var play := Button.new()
	play.position = Vector2(160.0, 195.0)
	play.size = Vector2(160.0, 48.0)
	play.text = "PLAY"
	play.add_theme_font_size_override("font_size", 22)
	play.add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
	play.add_theme_stylebox_override("normal", _btn_sb(Color(0.25, 0.45, 0.65, 0.8), Color(0.40, 0.60, 0.80, 0.5)))
	play.add_theme_stylebox_override("pressed", _btn_sb(Color(0.35, 0.55, 0.75, 0.9), Color(0.50, 0.70, 0.90, 0.6)))
	play.add_theme_stylebox_override("hover", _btn_sb(Color(0.30, 0.50, 0.70, 0.85), Color(0.45, 0.65, 0.85, 0.55)))
	play.pressed.connect(_on_menu_play)
	panel.add_child(play)

	var hint := Label.new()
	hint.text = "Press Enter to select level"
	hint.position = Vector2(0.0, 260.0)
	hint.size = Vector2(480.0, 24.0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.40, 0.40, 0.55))
	panel.add_child(hint)


func _build_level_select_overlay() -> void:
	_level_select_overlay = Control.new()
	_level_select_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_level_select_overlay.visible = false
	_root.add_child(_level_select_overlay)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.04, 0.08, 0.82)
	_level_select_overlay.add_child(dim)

	var panel := _styled_panel(
		Vector2(VIEW_W * 0.5 - 240.0, VIEW_H * 0.5 - 160.0),
		Vector2(480.0, 320.0),
		Color(0.08, 0.08, 0.14, 0.92),
		Color(0.30, 0.30, 0.50, 0.4),
		2.0
	)
	panel.name = "LevelSelectPanel"
	_level_select_overlay.add_child(panel)

	var title := Label.new()
	title.text = "SELECT LEVEL"
	title.position = Vector2(0.0, 24.0)
	title.size = Vector2(480.0, 50.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.90, 0.85, 0.65))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	panel.add_child(title)

	_level_select_overlay.set_meta("panel", panel)
	_level_select_overlay.set_meta("btn_start_y", 90.0)


func show_level_select(levels: Array[LevelDefinition]) -> void:
	_menu_overlay.visible = false
	_result_overlay.visible = false
	_level_select_overlay.visible = true
	set_gameplay_visible(false)
	_rebuild_level_buttons(levels)


func hide_level_select() -> void:
	_level_select_overlay.visible = false


func _rebuild_level_buttons(levels: Array[LevelDefinition]) -> void:
	var panel: Control = _level_select_overlay.get_meta("panel")
	for c in panel.get_children():
		if c is Button:
			c.queue_free()
	var y: float = float(_level_select_overlay.get_meta("btn_start_y"))
	for lvl: LevelDefinition in levels:
		var btn := Button.new()
		btn.size = Vector2(320.0, 48.0)
		btn.position = Vector2(80.0, y)
		var lvl_name: String = lvl.display_name
		var lvl_desc: String = lvl.description
		btn.text = "%s\n%s" % [lvl_name, lvl_desc]
		btn.add_theme_font_size_override("font_size", 14)
		btn.add_theme_color_override("font_color", Color(0.90, 0.90, 0.95))
		btn.add_theme_stylebox_override("normal", _btn_sb(Color(0.18, 0.20, 0.32, 0.8), Color(0.30, 0.35, 0.55, 0.4)))
		btn.add_theme_stylebox_override("pressed", _btn_sb(Color(0.28, 0.30, 0.45, 0.9), Color(0.40, 0.45, 0.65, 0.5)))
		btn.add_theme_stylebox_override("hover", _btn_sb(Color(0.23, 0.25, 0.38, 0.85), Color(0.35, 0.40, 0.60, 0.45)))
		var lid: int = lvl.id
		btn.pressed.connect(_on_level_btn.bind(lid))
		panel.add_child(btn)
		y += 56.0


func _on_level_btn(level_id: int) -> void:
	hide_level_select()
	level_selected.emit(level_id)


func _on_menu_play() -> void:
	hide_menu()
	hide_result()
	level_select_requested.emit()


func _build_result_overlay() -> void:
	_result_overlay = Control.new()
	_result_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_overlay.visible = false
	_root.add_child(_result_overlay)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.04, 0.08, 0.88)
	_result_overlay.add_child(dim)

	var panel := _styled_panel(
		Vector2(VIEW_W * 0.5 - 220.0, VIEW_H * 0.5 - 150.0),
		Vector2(440.0, 300.0),
		Color(0.08, 0.08, 0.14, 0.92),
		Color(0.30, 0.30, 0.50, 0.4),
		2.0
	)
	panel.name = "ResultPanel"
	_result_overlay.add_child(panel)

	_result_title = Label.new()
	_result_title.text = "Victory!"
	_result_title.position = Vector2(0.0, 40.0)
	_result_title.size = Vector2(440.0, 50.0)
	_result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_title.add_theme_font_size_override("font_size", 38)
	panel.add_child(_result_title)

	var div := ColorRect.new()
	div.position = Vector2(70.0, 100.0)
	div.size = Vector2(300.0, 1.0)
	div.color = Color(0.40, 0.35, 0.25, 0.3)
	panel.add_child(div)

	_result_sub = Label.new()
	_result_sub.text = ""
	_result_sub.position = Vector2(0.0, 115.0)
	_result_sub.size = Vector2(440.0, 30.0)
	_result_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_sub.add_theme_font_size_override("font_size", 15)
	_result_sub.add_theme_color_override("font_color", Color(0.70, 0.70, 0.80))
	panel.add_child(_result_sub)

	var again := Button.new()
	again.position = Vector2(120.0, 170.0)
	again.size = Vector2(200.0, 46.0)
	again.text = "Play Again"
	again.add_theme_font_size_override("font_size", 20)
	again.add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
	again.add_theme_stylebox_override("normal", _btn_sb(Color(0.20, 0.55, 0.30, 0.8), Color(0.30, 0.70, 0.45, 0.5)))
	again.add_theme_stylebox_override("pressed", _btn_sb(Color(0.30, 0.65, 0.40, 0.9), Color(0.40, 0.80, 0.55, 0.6)))
	again.add_theme_stylebox_override("hover", _btn_sb(Color(0.25, 0.60, 0.35, 0.85), Color(0.35, 0.75, 0.50, 0.55)))
	again.pressed.connect(_on_play)
	panel.add_child(again)

	var menu := Button.new()
	menu.position = Vector2(120.0, 226.0)
	menu.size = Vector2(200.0, 44.0)
	menu.text = "Main Menu"
	menu.add_theme_font_size_override("font_size", 18)
	menu.add_theme_color_override("font_color", Color(0.90, 0.90, 0.95))
	menu.add_theme_stylebox_override("normal", _btn_sb(Color(0.20, 0.22, 0.35, 0.7), Color(0.30, 0.35, 0.50, 0.4)))
	menu.add_theme_stylebox_override("pressed", _btn_sb(Color(0.30, 0.32, 0.45, 0.8), Color(0.40, 0.45, 0.60, 0.5)))
	menu.add_theme_stylebox_override("hover", _btn_sb(Color(0.25, 0.27, 0.40, 0.75), Color(0.35, 0.40, 0.55, 0.45)))
	menu.pressed.connect(func(): menu_requested.emit())
	panel.add_child(menu)


func _on_troop_btn(idx: int) -> void:
	spawn_requested.emit(idx)


func _on_play() -> void:
	hide_menu()
	hide_result()
	start_requested.emit()


func show_menu() -> void:
	_menu_overlay.visible = true
	_level_select_overlay.visible = false
	_result_overlay.visible = false
	set_gameplay_visible(false)


func hide_menu() -> void:
	_menu_overlay.visible = false


func hide_result() -> void:
	_result_overlay.visible = false


func show_result(won: bool) -> void:
	_result_title.text = "VICTORY!" if won else "DEFEAT..."
	if won:
		_result_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.42))
	else:
		_result_title.add_theme_color_override("font_color", Color(1.0, 0.45, 0.40))
	_result_sub.text = "You smashed the enemy base!" if won else "Your base has fallen. Try again!"
	_result_overlay.visible = true
	set_gameplay_visible(false)


func set_gameplay_visible(v: bool) -> void:
	for n in [_player_bar_container, _enemy_bar_container, _bottom_tray, _aim_up, _aim_down]:
		if is_instance_valid(n):
			n.visible = v
	for b in _troop_buttons:
		if is_instance_valid(b):
			b.visible = v


func update_hp(player_hp: float, enemy_hp: float, max_hp: float) -> void:
	_player_fill.size.x = 380.0 * clamp(player_hp / max_hp, 0.0, 1.0)
	_enemy_fill.size.x = 380.0 * clamp(enemy_hp / max_hp, 0.0, 1.0)
	_player_hp_label.text = "YOUR BASE  %d/%d" % [int(ceil(player_hp)), int(max_hp)]
	_enemy_hp_label.text = "%d/%d  ENEMY BASE" % [int(ceil(enemy_hp)), int(max_hp)]


func update_mana(mana: float, max_mana: float) -> void:
	_mana_fill.size.x = 150.0 * clamp(mana / max_mana, 0.0, 1.0)
	_mana_label.text = "%.1f / %d" % [snappedf(mana, 0.1), int(max_mana)]


func update_troop_buttons(mana: float) -> void:
	for i in _troop_buttons.size():
		var cost: float = _troop_data[i].cost
		_troop_buttons[i].disabled = mana < cost
