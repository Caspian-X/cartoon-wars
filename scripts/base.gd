class_name Base
extends Node2D

signal bolt_fired(start_pos: Vector2, angle: float, side: String)

var side: String = "player"
var hp: float = 180.0
var max_hp: float = 180.0
var has_crossbow: bool = true
var crossbow_angle: float = 0.0
var fire_timer: float = 0.6

var _dark: Color = Color(0.50, 0.55, 0.60)
var _light: Color = Color(0.65, 0.70, 0.75)
var _trim: Color = Color(0.35, 0.38, 0.42)
var _roof: Color = Color(0.42, 0.35, 0.28)
var _glow: Color = Color(0.0, 0.0, 0.0, 0.0)
var _time_sec: float = 0.0


func setup(p_side: String, p_max_hp: float) -> void:
	side = p_side
	max_hp = p_max_hp
	hp = p_max_hp
	if side == "enemy":
		has_crossbow = false
		_dark = Color(0.62, 0.35, 0.30)
		_light = Color(0.75, 0.45, 0.40)
		_trim = Color(0.45, 0.22, 0.18)
		_roof = Color(0.48, 0.28, 0.22)
		_glow = Color(1.0, 0.3, 0.25, 0.15)


func _process(dt: float) -> void:
	_time_sec += dt
	queue_redraw()


func update_crossbow(dt: float, target: Troop, _ground_y: float, pivot: Vector2) -> void:
	if not has_crossbow:
		return
	fire_timer -= dt
	if fire_timer <= 0.0:
		fire_timer = 1.4 + randf_range(-0.15, 0.15)
		bolt_fired.emit(pivot, crossbow_angle, side)

	if side == "enemy" and is_instance_valid(target):
		var dx: float = target.position.x - pivot.x
		var dy: float = target.position.y - 20.0 - pivot.y
		var target_angle: float = atan2(dy, abs(dx))
		crossbow_angle += (target_angle - crossbow_angle) * 0.06
	crossbow_angle = clamp(crossbow_angle, -0.4, 0.8)


func take_damage(amount: float) -> void:
	hp = max(0.0, hp - amount)


func _draw() -> void:
	var tw: float = 62.0
	var th: float = 96.0
	var top: float = -th

	# Ground shadow
	draw_colored_polygon(PackedVector2Array([
		Vector2(-tw * 0.5 - 6.0, 0.0),
		Vector2(-tw * 0.5 - 2.0, -4.0),
		Vector2(tw * 0.5 + 2.0, -4.0),
		Vector2(tw * 0.5 + 6.0, 0.0),
	]), Color(0.0, 0.0, 0.0, 0.25))

	# Stone foundation
	var base_h: float = 10.0
	draw_rect(Rect2(-tw * 0.5 - 3.0, top + th - base_h, tw + 6.0, base_h), _trim)
	for i in range(5):
		var sx: float = -tw * 0.5 - 3.0 + (tw + 6.0) * i / 5.0
		draw_line(Vector2(sx, top + th - base_h), Vector2(sx, top + th), Color(0, 0, 0, 0.15), 1.0)
		draw_line(Vector2(sx, top + th - base_h), Vector2(sx + (tw + 6.0) / 10.0, top + th - base_h), Color(0, 0, 0, 0.15), 1.0)

	# Main tower body with left-side shading
	var body_steps: int = 12
	for i in body_steps:
		var t: float = float(i) / float(body_steps)
		var y: float = top + t * th
		var h_step: float = th / float(body_steps) + 1.0
		var shade: float = lerp(1.0, 0.72, t)
		draw_rect(Rect2(-tw * 0.5, y, tw, h_step), _dark * shade)

	# Brick pattern (mortar lines)
	var brick_h: float = 8.0
	var rows: int = int(th / brick_h)
	for r in rows:
		var y: float = top + r * brick_h
		var offset: float = (r % 2) * 8.0
		var cols: int = int(tw / 14.0)
		for c in cols:
			var bx: float = -tw * 0.5 + 3.0 + c * 14.0 + offset
			if bx + 10.0 > tw * 0.5 - 3.0:
				continue
			# subtle brick shadow
			draw_rect(Rect2(bx + 1.0, y + 1.0, 10.0, brick_h - 1.0), Color(0, 0, 0, 0.06))
		draw_line(Vector2(-tw * 0.5 + 2.0, y), Vector2(tw * 0.5 - 2.0, y), Color(0, 0, 0, 0.12), 1.0)

	# Outer border
	draw_rect(Rect2(-tw * 0.5, top, tw, th), _trim, false, 2.5)

	# Door
	var door_w: float = 20.0
	var door_h: float = 28.0
	var door_top: float = top + th - base_h - door_h
	# Door frame
	draw_rect(Rect2(-door_w * 0.5 - 2.0, door_top, door_w + 4.0, door_h + 2.0), _trim)
	# Wood door
	draw_colored_polygon(PackedVector2Array([
		Vector2(-door_w * 0.5, door_top + door_h),
		Vector2(-door_w * 0.5, door_top + 10.0),
		Vector2(-door_w * 0.4, door_top),
		Vector2(door_w * 0.4, door_top),
		Vector2(door_w * 0.5, door_top + 10.0),
		Vector2(door_w * 0.5, door_top + door_h),
	]), Color(0.12, 0.09, 0.06))
	# Door arch
	draw_arc(Vector2(0.0, door_top + 10.0), door_w * 0.6, PI, 0.0, 8, Color(0.18, 0.14, 0.10), 1.5)
	# Iron bands
	draw_line(Vector2(-door_w * 0.5, door_top + door_h * 0.35), Vector2(door_w * 0.5, door_top + door_h * 0.35), Color(0.15, 0.12, 0.10), 1.5)
	draw_line(Vector2(-door_w * 0.5, door_top + door_h * 0.70), Vector2(door_w * 0.5, door_top + door_h * 0.70), Color(0.15, 0.12, 0.10), 1.5)

	# Windows with warm glow
	var win_y: float = top + th * 0.28
	var win_w: float = 9.0
	var win_h: float = 14.0
	for wx in [-13.0, 13.0]:
		# Window frame
		draw_rect(Rect2(wx - win_w * 0.5 - 1.0, win_y - 1.0, win_w + 2.0, win_h + 2.0), _trim)
		# Inner dark
		draw_rect(Rect2(wx - win_w * 0.5, win_y, win_w, win_h), Color(0.08, 0.06, 0.04))
		# Warm light glow
		var glow_c: Color = Color(1.0, 0.85, 0.40, 0.35) if side == "player" else Color(1.0, 0.45, 0.25, 0.35)
		draw_circle(Vector2(wx, win_y + win_h * 0.5), 5.0, glow_c)
		draw_rect(Rect2(wx - win_w * 0.5 + 1.0, win_y + 1.0, win_w - 2.0, win_h - 2.0), glow_c)
		# Cross bars
		draw_line(Vector2(wx, win_y + 1.0), Vector2(wx, win_y + win_h - 1.0), Color(0.10, 0.08, 0.06), 1.0)
		draw_line(Vector2(wx - win_w * 0.5 + 1.0, win_y + win_h * 0.5), Vector2(wx + win_w * 0.5 - 1.0, win_y + win_h * 0.5), Color(0.10, 0.08, 0.06), 1.0)

	# Battlements
	for i in range(-1, 2):
		var cx: float = i * 15.0
		var merlon_h: float = 10.0
		var mw: float = 12.0
		# Merlon shadow
		draw_rect(Rect2(cx - mw * 0.5 + 1.0, top - merlon_h + 1.0, mw, merlon_h), Color(0, 0, 0, 0.15))
		draw_rect(Rect2(cx - mw * 0.5, top - merlon_h, mw, merlon_h), _light)
		draw_rect(Rect2(cx - mw * 0.5, top - merlon_h, mw, merlon_h), _trim, false, 1.5)
		# Highlight top
		draw_line(Vector2(cx - mw * 0.5 + 1.0, top - merlon_h + 1.0), Vector2(cx + mw * 0.5 - 1.0, top - merlon_h + 1.0), Color(1.0, 1.0, 1.0, 0.15), 1.0)
		# Crenel detail
		draw_circle(Vector2(cx, top - merlon_h + 3.0), 1.5, Color(0.9, 0.9, 0.9, 0.25))

	# Roof / cornice
	draw_rect(Rect2(-22.0, top - 2.0, 44.0, 5.0), _roof)
	draw_line(Vector2(-24.0, top - 2.0), Vector2(24.0, top - 2.0), _trim, 2.0)
	# Roof highlight
	draw_line(Vector2(-22.0, top - 1.0), Vector2(22.0, top - 1.0), Color(1.0, 1.0, 1.0, 0.1), 1.0)

	_draw_flag(top)
	if has_crossbow:
		_draw_crossbow(top)


func _draw_flag(top: float) -> void:
	var pole_top: float = top - 26.0
	# Flag pole
	draw_line(Vector2(0.0, top - 2.0), Vector2(0.0, pole_top), Color(0.45, 0.40, 0.35), 2.5)
	# Pole finial
	draw_circle(Vector2(0.0, pole_top), 2.0, Color(0.7, 0.65, 0.55))

	var flag_color: Color
	var flag_icon_color: Color
	if side == "player":
		flag_color = Color(0.25, 0.50, 0.85)
		flag_icon_color = Color(0.90, 0.95, 1.0)
	else:
		flag_color = Color(0.75, 0.20, 0.15)
		flag_icon_color = Color(1.0, 0.85, 0.70)

	# Animated waving flag
	var wave: float = sin(_time_sec * 3.0) * 2.0
	var wave2: float = sin(_time_sec * 3.0 + 1.0) * 1.5
	var flag_points := PackedVector2Array([
		Vector2(0.0, pole_top + 2.0),
		Vector2(24.0, pole_top + 10.0 + wave),
		Vector2(0.0, pole_top + 18.0 + wave2),
	])
	draw_colored_polygon(flag_points, flag_color)
	draw_polyline(PackedVector2Array([flag_points[0], flag_points[1], flag_points[2]]), Color(0, 0, 0, 0.25), 1.0)

	if side == "player":
		draw_line(Vector2(7.0, pole_top + 7.0 + wave * 0.3), Vector2(7.0, pole_top + 15.0 + wave * 0.3), flag_icon_color, 2.0)
		draw_line(Vector2(7.0, pole_top + 7.0 + wave * 0.3), Vector2(15.0, pole_top + 11.0 + wave * 0.3), flag_icon_color, 2.0)
		draw_line(Vector2(7.0, pole_top + 15.0 + wave * 0.3), Vector2(15.0, pole_top + 11.0 + wave * 0.3), flag_icon_color, 2.0)
	else:
		draw_line(Vector2(6.0, pole_top + 7.0 + wave * 0.3), Vector2(6.0, pole_top + 15.0 + wave * 0.3), flag_icon_color, 2.0)
		draw_line(Vector2(6.0, pole_top + 7.0 + wave * 0.3), Vector2(14.0, pole_top + 11.0 + wave * 0.3), flag_icon_color, 2.0)
		draw_line(Vector2(6.0, pole_top + 15.0 + wave * 0.3), Vector2(14.0, pole_top + 11.0 + wave * 0.3), flag_icon_color, 2.0)
		draw_line(Vector2(6.0, pole_top + 11.0 + wave * 0.3), Vector2(14.0, pole_top + 7.0 + wave * 0.3), flag_icon_color, 2.0)
		draw_line(Vector2(6.0, pole_top + 11.0 + wave * 0.3), Vector2(14.0, pole_top + 15.0 + wave * 0.3), flag_icon_color, 2.0)


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

	# Main stock
	draw_rect(Rect2(-3.0, -6.0, 34.0, 12.0), Color(0.38, 0.24, 0.12))
	draw_rect(Rect2(-3.0, -6.0, 34.0, 12.0), Color(0.20, 0.12, 0.05), false, 1.0)
	# Stock highlight
	draw_line(Vector2(-2.0, -5.0), Vector2(30.0, -5.0), Color(1.0, 1.0, 1.0, 0.08), 1.0)

	# Tiller / handle
	draw_rect(Rect2(26.0, -12.0, 10.0, 24.0), Color(0.32, 0.20, 0.10))
	draw_rect(Rect2(26.0, -12.0, 10.0, 24.0), Color(0.18, 0.10, 0.04), false, 1.0)

	# Bow limbs
	draw_line(Vector2(10.0, -6.0), Vector2(34.0, -6.0), Color(0.15, 0.10, 0.05), 1.5)
	draw_line(Vector2(10.0, 6.0), Vector2(34.0, 6.0), Color(0.15, 0.10, 0.05), 1.5)

	# Bow arc (prow)
	draw_arc(Vector2(34.0, 0.0), 20.0, -1.2, 1.2, 16, Color(0.60, 0.60, 0.65), 3.5)
	draw_arc(Vector2(34.0, 0.0), 20.0, -1.2, 1.2, 16, Color(0.35, 0.35, 0.40), 1.5, true)

	# Bowstring
	draw_line(Vector2(8.0, 0.0), Vector2(32.0, 0.0), Color(0.35, 0.23, 0.12), 2.0)

	# String tension lines
	draw_line(Vector2(8.0, 0.0), Vector2(30.0, -7.0), Color(0.50, 0.50, 0.55, 0.8), 1.5)
	draw_line(Vector2(8.0, 0.0), Vector2(30.0, 7.0), Color(0.50, 0.50, 0.55, 0.8), 1.5)

	# Bolt loaded
	var bolt_tip := PackedVector2Array([Vector2(38.0, 0.0), Vector2(32.0, -4.5), Vector2(32.0, 4.5)])
	draw_colored_polygon(bolt_tip, Color(0.70, 0.70, 0.75))
	draw_polyline(PackedVector2Array([bolt_tip[0], bolt_tip[1], bolt_tip[0], bolt_tip[2]]), Color(0.35, 0.35, 0.40), 1.0)

	draw_set_transform_matrix(Transform2D())
