class_name Troop
extends Node2D

var side: String = "player"
var type_idx: int = 0
var data: Dictionary = {}
var hp: float = 35.0
var max_hp: float = 35.0
var frac: float = 0.0
var y_jitter: float = 0.0
var atk_timer: float = 0.0
var phase: float = 0.0
var state: String = "walk"
var hit_flash: float = 0.0
var alive: bool = true

var bg_bar: ColorRect
var fill_bar: ColorRect


func setup(p_side: String, p_type_idx: int, p_data: Dictionary) -> void:
	side = p_side
	type_idx = p_type_idx
	data = p_data
	hp = float(data.get("hp", 35.0))
	max_hp = hp
	frac = 1.0 if side == "enemy" else 0.0
	y_jitter = randf() * 16.0 - 8.0
	phase = randf() * TAU
	name = "%s_%s_%d" % [String(data.get("key", "troop")), side, get_instance_id()]


func _ready() -> void:
	bg_bar = ColorRect.new()
	add_child(bg_bar)
	fill_bar = ColorRect.new()
	add_child(fill_bar)
	var bar_w: float = _bar_w()
	bg_bar.size = Vector2(bar_w + 2.0, 5.0)
	bg_bar.color = Color(0.0, 0.0, 0.0, 0.6)
	fill_bar.size = Vector2(bar_w, 3.0)
	fill_bar.color = Color(0.3, 0.9, 0.2)


func update_visuals(dt: float, _time_sec: float) -> void:
	if not alive:
		return
	phase += dt * 10.0
	if hit_flash > 0.0:
		hit_flash -= dt
	queue_redraw()


func _draw() -> void:
	if not alive:
		return
	var s: float = float(data.get("scale", 0.13))
	var fact: float = s / 0.13
	var facing: float = 1.0 if side == "player" else -1.0
	var flash: bool = hit_flash > 0.0 and int(hit_flash * 50.0) % 2 == 0

	# Ground shadow
	var shadow_w: float = 10.0 * fact
	var shadow_h: float = 2.5 * fact
	var shadow_pts := PackedVector2Array()
	for i in range(8):
		var ang: float = float(i) / 8.0 * TAU
		shadow_pts.append(Vector2(cos(ang) * shadow_w, sin(ang) * shadow_h))
	draw_colored_polygon(shadow_pts, Color(0.0, 0.0, 0.0, 0.25))

	var skin_col := Color(0.95, 0.88, 0.80)
	var body_col: Color
	var wpn_col: Color
	var acc_col: Color

	var key: String = String(data.get("key", "spearman"))
	match key:
		"spearman":
			body_col = Color(0.25, 0.45, 0.75)
			wpn_col = Color(0.55, 0.50, 0.45)
			acc_col = Color(0.90, 0.75, 0.30)
		"bowman":
			body_col = Color(0.20, 0.60, 0.30)
			wpn_col = Color(0.50, 0.35, 0.20)
			acc_col = Color(0.80, 0.70, 0.40)
		"wizard":
			body_col = Color(0.45, 0.25, 0.65)
			wpn_col = Color(0.70, 0.55, 0.90)
			acc_col = Color(0.90, 0.80, 0.30)
		"broadsword":
			body_col = Color(0.65, 0.18, 0.18)
			wpn_col = Color(0.70, 0.70, 0.75)
			acc_col = Color(0.90, 0.75, 0.20)
		"golem":
			body_col = Color(0.35, 0.35, 0.40)
			wpn_col = Color(0.45, 0.40, 0.35)
			acc_col = Color(0.70, 0.20, 0.10)
		"skeleton":
			body_col = Color(0.85, 0.82, 0.75)
			wpn_col = Color(0.60, 0.55, 0.45)
			acc_col = Color(0.50, 0.30, 0.20)
		"imp":
			body_col = Color(0.50, 0.10, 0.15)
			wpn_col = Color(0.90, 0.55, 0.10)
			acc_col = Color(0.80, 0.20, 0.10)
		_:
			body_col = Color(0.25, 0.45, 0.75)
			wpn_col = Color(0.55, 0.50, 0.45)
			acc_col = Color(0.90, 0.75, 0.30)

	if flash:
		body_col = Color.WHITE
		wpn_col = Color.WHITE
		acc_col = Color.WHITE
		skin_col = Color.WHITE

	var head_r: float = 8.0 * fact
	var body_len: float = 18.0 * fact
	var arm_len: float = 12.0 * fact
	var leg_len: float = 14.0 * fact

	var bob: float = 0.0
	var lunge: float = 0.0
	if state == "walk":
		bob = -abs(sin(phase)) * 3.0 * fact
	else:
		lunge = sin(phase * 1.5) * 3.0 * fact * facing

	var leg_swing: float = sin(phase) * 5.0 * fact
	var arm_swing: float = sin(phase + PI) * 3.0 * fact

	var bx: float = lunge
	var by: float = bob

	var neck_y: float = by - head_r * 0.5 - body_len * 0.5
	var head_c := Vector2(bx, neck_y - head_r * 0.5)
	draw_circle(head_c, head_r + 1.0, Color(0, 0, 0, 0.25))
	draw_circle(head_c, head_r, skin_col)

	var body_top := Vector2(bx, neck_y)
	var body_bot := Vector2(bx, neck_y + body_len)
	var body_thick: float = max(2.5, 3.0 * fact)
	draw_line(body_top, body_bot, body_col, body_thick)

	if key == "broadsword":
		draw_rect(Rect2(bx - 4.0 * fact, neck_y + 2.0 * fact, 8.0 * fact, body_len - 4.0 * fact), Color(0, 0, 0, 0.08))
		draw_rect(Rect2(bx - 4.0 * fact, neck_y + 2.0 * fact, 8.0 * fact, body_len - 4.0 * fact), body_col, false, 1.0)
	elif key == "wizard":
		draw_rect(Rect2(bx - 4.0 * fact, neck_y + 1.0 * fact, 8.0 * fact, body_len - 2.0 * fact), Color(0.35, 0.18, 0.50, 0.4))
		draw_line(Vector2(bx - 3.0 * fact, neck_y + 2.0), Vector2(bx + 3.0 * fact, neck_y + body_len - 2.0), Color(0.7, 0.6, 0.5, 0.2), 1.0)
		draw_line(Vector2(bx + 3.0 * fact, neck_y + 2.0), Vector2(bx - 3.0 * fact, neck_y + body_len - 2.0), Color(0.7, 0.6, 0.5, 0.2), 1.0)
	if key == "golem":
		draw_rect(Rect2(bx - 5.0 * fact, neck_y + 1.0 * fact, 10.0 * fact, body_len - 2.0 * fact), Color(0, 0, 0, 0.15))
		draw_rect(Rect2(bx - 5.0 * fact, neck_y + 1.0 * fact, 10.0 * fact, body_len - 2.0 * fact), body_col, false, 1.5)
	if key == "skeleton":
		draw_circle(head_c + Vector2(-3.0 * fact, -1.0 * fact), 1.5 * fact, Color(0.1, 0.1, 0.1, 0.8))
		draw_circle(head_c + Vector2(3.0 * fact, -1.0 * fact), 1.5 * fact, Color(0.1, 0.1, 0.1, 0.8))
		draw_line(head_c + Vector2(-3.0 * fact, 4.0 * fact), head_c + Vector2(3.0 * fact, 4.0 * fact), Color(0.1, 0.1, 0.1, 0.6), 1.0)
	if key == "imp":
		draw_line(head_c + Vector2(-3.0 * fact, -head_r), head_c + Vector2(-6.0 * fact, -head_r - 5.0 * fact), Color(0.3, 0.05, 0.05), 2.0 * fact)
		draw_line(head_c + Vector2(3.0 * fact, -head_r), head_c + Vector2(6.0 * fact, -head_r - 5.0 * fact), Color(0.3, 0.05, 0.05), 2.0 * fact)

	var shldr := Vector2(bx, neck_y + body_len * 0.15)
	var hip := Vector2(bx, neck_y + body_len * 0.75)

	var back_arm := shldr + Vector2(-arm_len * 0.7 * facing, arm_swing * 1.5)
	var front_arm := shldr + Vector2(arm_len * 0.5 * facing, -arm_swing * 0.8)

	if state == "attack":
		if key == "spearman":
			front_arm = shldr + Vector2(arm_len * 1.0 * facing, -arm_len * 0.3)
			back_arm = shldr + Vector2(-arm_len * 0.3 * facing, -arm_len * 0.1)
		elif key == "broadsword":
			front_arm = shldr + Vector2(arm_len * 0.8 * facing, -arm_len * 0.6)
			back_arm = shldr + Vector2(-arm_len * 0.5 * facing, arm_len * 0.2)
		else:
			front_arm = shldr + Vector2(arm_len * 0.7 * facing, -arm_len * 0.2)

	draw_line(shldr, back_arm, body_col, 1.5)
	draw_line(shldr, front_arm, body_col, 1.5)

	var f_leg := hip + Vector2(-leg_swing * 0.5, leg_len)
	var b_leg := hip + Vector2(leg_swing * 0.5, leg_len)
	draw_line(hip, f_leg, Color(0.25, 0.20, 0.18), 2.0 * fact)
	draw_line(hip, b_leg, Color(0.25, 0.20, 0.18), 2.0 * fact)
	draw_circle(f_leg, 2.0 * fact, Color(0.20, 0.16, 0.14))
	draw_circle(b_leg, 2.0 * fact, Color(0.20, 0.16, 0.14))

	_draw_weapon(key, shldr, front_arm, facing, wpn_col, acc_col, flash, fact)
	_draw_hp_bar(s)


func _draw_weapon(key: String, _shldr: Vector2, hand: Vector2, facing: float, wcol: Color, acol: Color, flash: bool, fact: float) -> void:
	match key:
		"spearman":
			var tip := hand + Vector2(16.0 * fact * facing, -6.0 * fact)
			draw_line(hand, tip, Color(0.40, 0.35, 0.28), max(1.5, 2.0 * fact))
			draw_line(tip, tip + Vector2(1.0 * facing, -5.0 * fact), Color(0.60, 0.55, 0.50), 2.0 * fact)
			draw_line(tip, tip + Vector2(3.0 * facing, -3.0 * fact), Color(0.60, 0.55, 0.50), 1.5 * fact)
			draw_line(tip, tip + Vector2(-1.0 * facing, -5.0 * fact), Color(0.60, 0.55, 0.50), 1.0 * fact)
		"bowman":
			var bow_mid := hand + Vector2(4.0 * facing * fact, 0.0)
			var bow_top := bow_mid + Vector2(0.0, -10.0 * fact)
			var bow_bot := bow_mid + Vector2(0.0, 10.0 * fact)
			draw_line(bow_top, bow_bot, Color(0.45, 0.30, 0.18), 2.0 * fact)
			draw_arc(bow_mid, 11.0 * fact, -1.3, 1.3, 8, Color(0.50, 0.35, 0.22), 1.5 * fact)
			draw_line(hand + Vector2(2.0 * facing * fact, 0.0), bow_top + Vector2(0.0, 1.0), Color(0.6, 0.6, 0.6, 0.7), 1.0)
			draw_line(hand + Vector2(2.0 * facing * fact, 0.0), bow_bot + Vector2(0.0, -1.0), Color(0.6, 0.6, 0.6, 0.7), 1.0)
		"wizard":
			var staff_top := hand + Vector2(-5.0 * facing * fact, -12.0 * fact)
			var staff_bot := hand + Vector2(2.0 * facing * fact, 10.0 * fact)
			draw_line(staff_bot, staff_top, Color(0.40, 0.30, 0.20), 2.5 * fact)
			draw_circle(staff_top, 4.5 * fact, Color(0.65, 0.50, 0.90, 0.5))
			draw_circle(staff_top, 2.5 * fact, wcol)
			if not flash:
				draw_circle(staff_top + Vector2(facing * 3.0 * fact, -2.0 * fact), 1.5 * fact, Color(0.9, 0.8, 1.0, 0.9))
				draw_circle(staff_top + Vector2(facing * -1.0 * fact, 4.0 * fact), 1.0 * fact, Color(0.8, 0.7, 1.0, 0.6))
		"broadsword":
			var tip := hand + Vector2(14.0 * fact * facing, -8.0 * fact)
			draw_line(hand, tip, Color(0.65, 0.65, 0.70), 2.5 * fact)
			draw_line(hand + Vector2(-2.0 * fact * facing, -3.0 * fact), hand + Vector2(-2.0 * fact * facing, 3.0 * fact), acol, 2.0 * fact)
			draw_line(hand, hand - Vector2(3.0 * fact * facing, 0.0), Color(0.35, 0.25, 0.18), 2.0 * fact)
			draw_circle(tip, 1.0, Color(0.85, 0.85, 0.90))
		"golem":
			var tip := hand + Vector2(12.0 * fact * facing, -4.0 * fact)
			draw_line(hand, tip, Color(0.50, 0.45, 0.40), max(2.0, 3.0 * fact))
			draw_circle(tip, 3.0 * fact, Color(0.45, 0.40, 0.35))
		"skeleton":
			var bow_mid := hand + Vector2(4.0 * facing * fact, 0.0)
			var bow_top := bow_mid + Vector2(0.0, -10.0 * fact)
			var bow_bot := bow_mid + Vector2(0.0, 10.0 * fact)
			draw_line(bow_top, bow_bot, Color(0.70, 0.65, 0.55), 2.0 * fact)
			draw_arc(bow_mid, 11.0 * fact, -1.3, 1.3, 8, Color(0.75, 0.70, 0.60), 1.5 * fact)
			draw_line(hand + Vector2(2.0 * facing * fact, 0.0), bow_top + Vector2(0.0, 1.0), Color(0.6, 0.6, 0.6, 0.7), 1.0)
			draw_line(hand + Vector2(2.0 * facing * fact, 0.0), bow_bot + Vector2(0.0, -1.0), Color(0.6, 0.6, 0.6, 0.7), 1.0)
		"imp":
			var staff_top := hand + Vector2(-5.0 * facing * fact, -10.0 * fact)
			var staff_bot := hand + Vector2(2.0 * facing * fact, 8.0 * fact)
			draw_line(staff_bot, staff_top, Color(0.40, 0.20, 0.15), 2.0 * fact)
			draw_circle(staff_top, 4.0 * fact, Color(0.90, 0.40, 0.10, 0.4))
			draw_circle(staff_top, 2.5 * fact, Color(0.90, 0.55, 0.10))
			if not flash:
				draw_circle(staff_top + Vector2(facing * 3.0 * fact, -2.0 * fact), 1.5 * fact, Color(1.0, 0.7, 0.2, 0.9))
				draw_circle(staff_top + Vector2(facing * -1.0 * fact, 3.0 * fact), 1.0 * fact, Color(0.9, 0.5, 0.1, 0.6))


func _bar_w() -> float:
	return 22.0 * float(data.get("scale", 0.13)) / 0.13


func _draw_hp_bar(s: float) -> void:
	var fact: float = s / 0.13
	var bar_w: float = 22.0 * fact
	var bar_y: float = -8.0 * fact - 14.0 * fact - 10.0 * fact
	bg_bar.position = Vector2(-bar_w * 0.5 - 1.0, bar_y - 1.0)
	bg_bar.size.x = bar_w + 2.0
	fill_bar.position = Vector2(-bar_w * 0.5, bar_y)
	var ratio: float = clamp(hp / max_hp, 0.0, 1.0)
	fill_bar.size.x = bar_w * ratio
	var hue: float = ratio * 120.0
	fill_bar.color = Color.from_hsv(hue / 360.0, 0.85, 0.40)


func take_damage(amount: float) -> void:
	hp = max(0.0, hp - amount)
	hit_flash = 0.12
	if hp <= 0.0:
		alive = false
