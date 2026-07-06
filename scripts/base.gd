class_name Base
extends Node2D

signal bolt_fired(start_pos: Vector2, end_pos: Vector2, target: Troop)

var side: String = "player"
var hp: float = 180.0
var max_hp: float = 180.0
var crossbow_angle: float = 0.0
var fire_timer: float = 0.6

var _dark: Color = Color(0.35, 0.38, 0.41)
var _light: Color = Color(0.48, 0.51, 0.55)
var _trim: Color = Color(0.23, 0.25, 0.28)
var _roof: Color = Color(0.29, 0.23, 0.16)
var _glow: Color = Color(0.0, 0.0, 0.0, 0.0)
var bg_bar: ColorRect
var fill_bar: ColorRect


func setup(p_side: String, p_max_hp: float) -> void:
	side = p_side
	max_hp = p_max_hp
	hp = p_max_hp
	if side == "enemy":
		_dark = Color(0.40, 0.16, 0.12)
		_light = Color(0.55, 0.22, 0.18)
		_trim = Color(0.28, 0.10, 0.07)
		_roof = Color(0.32, 0.14, 0.10)
		_glow = Color(1.0, 0.2, 0.15, 0.15)


func _ready() -> void:
	bg_bar = ColorRect.new()
	add_child(bg_bar)
	fill_bar = ColorRect.new()
	add_child(fill_bar)
	bg_bar.size = Vector2(90.0, 10.0)
	bg_bar.color = Color(0.0, 0.0, 0.0, 0.7)
	bg_bar.material = null
	fill_bar.size = Vector2(86.0, 6.0)
	if side == "player":
		fill_bar.color = Color(0.40, 0.78, 1.0)
	else:
		fill_bar.color = Color(1.0, 0.35, 0.28)
	_refresh_hp_bar()


func update_crossbow(dt: float, target: Troop, _ground_y: float, pivot: Vector2) -> void:
	fire_timer -= dt
	if fire_timer <= 0.0:
		fire_timer = 1.4 + randf_range(-0.15, 0.15)
		if is_instance_valid(target):
			bolt_fired.emit(pivot, Vector2(target.position.x, target.position.y - 20.0), target)

	if side == "enemy" and is_instance_valid(target):
		var dx: float = target.position.x - pivot.x
		var dy: float = target.position.y - 20.0 - pivot.y
		var target_angle: float = atan2(dy, abs(dx))
		crossbow_angle += (target_angle - crossbow_angle) * 0.06
	crossbow_angle = clamp(crossbow_angle, -0.4, 0.8)


func take_damage(amount: float) -> void:
	hp = max(0.0, hp - amount)
	_refresh_hp_bar()


func _refresh_hp_bar() -> void:
	var top_y: float = -90.0 - 14.0
	bg_bar.position = Vector2(-45.0, top_y)
	fill_bar.position = Vector2(-43.0, top_y + 2.0)
	var ratio: float = clamp(hp / max_hp, 0.0, 1.0)
	fill_bar.size.x = 86.0 * ratio


func _draw() -> void:
	var tw: float = 58.0
	var th: float = 90.0
	var top: float = -th

	if _glow.a > 0:
		draw_circle(Vector2(0.0, -th * 0.45), 60.0, _glow)

	draw_rect(Rect2(-tw * 0.5, top, tw, th), _dark)

	var rng := RandomNumberGenerator.new()
	for _b in range(14):
		var bx: float = rng.randf_range(-tw * 0.5 + 2.0, tw * 0.5 - 2.0)
		var by: float = rng.randf_range(top + 4.0, top + th - 6.0)
		var bw: float = rng.randf_range(6.0, 14.0)
		var bh: float = rng.randf_range(4.0, 8.0)
		draw_rect(Rect2(bx, by, bw, bh), Color(0, 0, 0, 0.08))

	for r in range(1, 7):
		var y: float = top + (th / 7.0) * r
		draw_line(Vector2(-tw * 0.5, y), Vector2(tw * 0.5, y), Color(0, 0, 0, 0.10), 1.0)

	draw_rect(Rect2(-tw * 0.5, top, tw, th), _trim, false, 2.5)

	var door_w: float = 18.0
	var door_h: float = 26.0
	var door_top: float = top + th - door_h
	draw_colored_polygon(PackedVector2Array([
		Vector2(-door_w * 0.5, door_top + door_h),
		Vector2(-door_w * 0.5, door_top + 8.0),
		Vector2(-door_w * 0.4, door_top),
		Vector2(door_w * 0.4, door_top),
		Vector2(door_w * 0.5, door_top + 8.0),
		Vector2(door_w * 0.5, door_top + door_h),
	]), Color(0.08, 0.06, 0.05))
	draw_arc(Vector2(0.0, door_top + 8.0), door_w * 0.6, PI, 0.0, 8, Color(0.15, 0.12, 0.10), 1.5)
	draw_line(Vector2(-door_w * 0.5, door_top + door_h), Vector2(-door_w * 0.5, door_top + 8.0), Color(0.15, 0.12, 0.10), 1.5)
	draw_line(Vector2(door_w * 0.5, door_top + door_h), Vector2(door_w * 0.5, door_top + 8.0), Color(0.15, 0.12, 0.10), 1.5)

	var win_y: float = top + th * 0.3
	var win_w: float = 8.0
	var win_h: float = 12.0
	for wx in [-12.0, 12.0]:
		draw_rect(Rect2(wx - win_w * 0.5, win_y, win_w, win_h), Color(0.15, 0.10, 0.08))
		draw_rect(Rect2(wx - win_w * 0.5 + 1.0, win_y + 1.0, win_w - 2.0, win_h - 2.0), Color(1.0, 0.90, 0.55, 0.3))
		draw_line(Vector2(wx, win_y + 1.0), Vector2(wx, win_y + win_h - 1.0), Color(0.12, 0.08, 0.06), 1.0)
		draw_line(Vector2(wx - win_w * 0.5 + 1.0, win_y + win_h * 0.5), Vector2(wx + win_w * 0.5 - 1.0, win_y + win_h * 0.5), Color(0.12, 0.08, 0.06), 1.0)

	for i in range(-1, 2):
		var cx: float = i * 14.0
		var merlon_h: float = 10.0
		draw_rect(Rect2(cx - 6.0, top - merlon_h, 12.0, merlon_h), _light)
		draw_rect(Rect2(cx - 6.0, top - merlon_h, 12.0, merlon_h), _trim, false, 1.5)
		draw_circle(Vector2(cx, top - merlon_h + 3.0), 1.5, Color(0.9, 0.9, 0.9, 0.3))

	draw_rect(Rect2(-20.0, top - 2.0, 40.0, 5.0), _roof)
	draw_line(Vector2(-22.0, top - 2.0), Vector2(22.0, top - 2.0), _trim, 2.0)

	_draw_flag(top)
	_draw_crossbow(top)


func _draw_flag(top: float) -> void:
	var pole_top: float = top - 22.0
	draw_line(Vector2(0.0, top - 2.0), Vector2(0.0, pole_top), Color(0.4, 0.35, 0.3), 2.0)
	draw_circle(Vector2(0.0, pole_top), 1.5, Color(0.6, 0.55, 0.5))

	var flag_color: Color
	var flag_icon_color: Color
	if side == "player":
		flag_color = Color(0.25, 0.50, 0.85)
		flag_icon_color = Color(0.90, 0.95, 1.0)
	else:
		flag_color = Color(0.75, 0.20, 0.15)
		flag_icon_color = Color(1.0, 0.85, 0.70)

	var flag_points := PackedVector2Array([
		Vector2(0.0, pole_top + 2.0),
		Vector2(22.0, pole_top + 10.0),
		Vector2(0.0, pole_top + 18.0),
	])
	draw_colored_polygon(flag_points, flag_color)
	draw_polyline(PackedVector2Array([flag_points[0], flag_points[1], flag_points[2]]), Color(0, 0, 0, 0.25), 1.0)

	if side == "player":
		draw_line(Vector2(6.0, pole_top + 6.0), Vector2(6.0, pole_top + 14.0), flag_icon_color, 2.0)
		draw_line(Vector2(6.0, pole_top + 6.0), Vector2(14.0, pole_top + 10.0), flag_icon_color, 2.0)
		draw_line(Vector2(6.0, pole_top + 14.0), Vector2(14.0, pole_top + 10.0), flag_icon_color, 2.0)
	else:
		draw_line(Vector2(5.0, pole_top + 6.0), Vector2(5.0, pole_top + 14.0), flag_icon_color, 2.0)
		draw_line(Vector2(5.0, pole_top + 6.0), Vector2(13.0, pole_top + 10.0), flag_icon_color, 2.0)
		draw_line(Vector2(5.0, pole_top + 14.0), Vector2(13.0, pole_top + 10.0), flag_icon_color, 2.0)
		draw_line(Vector2(5.0, pole_top + 10.0), Vector2(13.0, pole_top + 6.0), flag_icon_color, 2.0)
		draw_line(Vector2(5.0, pole_top + 10.0), Vector2(13.0, pole_top + 14.0), flag_icon_color, 2.0)


func _draw_crossbow(top: float) -> void:
	var pivot := Vector2(0.0, top - 4.0)
	var flip_x: float = 1.0 if side == "player" else -1.0
	var c: float = cos(crossbow_angle)
	var s: float = sin(crossbow_angle)
	var t := Transform2D()
	t.x = Vector2(c * flip_x, s * flip_x)
	t.y = Vector2(-s, c)
	t.origin = pivot
	draw_set_transform_matrix(t)

	draw_rect(Rect2(-2.0, -5.0, 30.0, 10.0), Color(0.35, 0.22, 0.10))
	draw_rect(Rect2(-2.0, -5.0, 30.0, 10.0), Color(0.20, 0.12, 0.05), false, 1.0)

	draw_rect(Rect2(24.0, -10.0, 8.0, 20.0), Color(0.30, 0.18, 0.08))

	draw_line(Vector2(8.0, -5.0), Vector2(32.0, -5.0), Color(0.15, 0.10, 0.05), 1.5)
	draw_line(Vector2(8.0, 5.0), Vector2(32.0, 5.0), Color(0.15, 0.10, 0.05), 1.5)

	draw_arc(Vector2(32.0, 0.0), 18.0, -1.2, 1.2, 14, Color(0.55, 0.55, 0.60), 3.5)
	draw_arc(Vector2(32.0, 0.0), 18.0, -1.2, 1.2, 14, Color(0.35, 0.35, 0.40), 1.5, true)

	draw_line(Vector2(6.0, 0.0), Vector2(30.0, 0.0), Color(0.35, 0.23, 0.12), 2.0)

	draw_line(Vector2(6.0, 0.0), Vector2(28.0, -6.0), Color(0.50, 0.50, 0.55, 0.8), 1.5)
	draw_line(Vector2(6.0, 0.0), Vector2(28.0, 6.0), Color(0.50, 0.50, 0.55, 0.8), 1.5)

	var bolt_tip := PackedVector2Array([Vector2(36.0, 0.0), Vector2(31.0, -4.0), Vector2(31.0, 4.0)])
	draw_colored_polygon(bolt_tip, Color(0.65, 0.65, 0.70))
	draw_polyline(PackedVector2Array([bolt_tip[0], bolt_tip[1], bolt_tip[0], bolt_tip[2]]), Color(0.35, 0.35, 0.40), 1.0)

	draw_set_transform_matrix(Transform2D())
