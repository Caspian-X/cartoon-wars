class_name Troop
extends Node2D

const FLAMETHROWER_MODEL := preload("res://scenes/units/soldier_flamethrower_model.tscn")
const SPEARMAN_MODEL := preload("res://scenes/units/spearman_model.tscn")
const WIZARD_MODEL := preload("res://scenes/units/wizard_model.tscn")

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
var dying: bool = false
var death_timer: float = 0.0

var bg_bar: ColorRect
var fill_bar: ColorRect
var character_sprite: Sprite2D
var character_2d_sprite: AnimatedSprite2D
var character_model: Node3D
var character_model_position: Vector3
var character_animation: AnimationPlayer
var character_animation_name := ""
var animated_parts: Dictionary = {}


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
	var key := String(data.get("key", ""))
	var model_resource: PackedScene
	match key:
		"spearman":
			model_resource = SPEARMAN_MODEL
		"wizard":
			model_resource = WIZARD_MODEL
		"soldier_flamethrower":
			model_resource = FLAMETHROWER_MODEL
	if key == "broadsword":
		_setup_broadsword_2d()
	elif model_resource:
		var viewport := SubViewport.new()
		viewport.size = Vector2i(256, 256)
		viewport.transparent_bg = true
		viewport.own_world_3d = true
		viewport.world_3d = World3D.new()
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		var environment := Environment.new()
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.ambient_light_color = Color(0.72, 0.78, 0.9)
		environment.ambient_light_energy = 1.1
		var world_environment := WorldEnvironment.new()
		world_environment.environment = environment
		viewport.add_child(world_environment)
		var key_light := DirectionalLight3D.new()
		key_light.rotation_degrees = Vector3(-42.0, -28.0, 0.0)
		key_light.light_color = Color(1.0, 0.91, 0.78)
		key_light.light_energy = 1.6
		key_light.shadow_enabled = true
		viewport.add_child(key_light)
		var model_scene := model_resource.instantiate()
		viewport.add_child(model_scene)
		var model_camera := model_scene.get_node_or_null("Camera") as Camera3D
		if model_camera:
			model_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
			model_camera.position = Vector3(5.0, 2.0, 4.5) if key != "soldier_flamethrower" else Vector3(6.0, 1.65, 0.0)
			model_camera.look_at_from_position(model_camera.position, Vector3(0.0, 1.45, 0.0), Vector3.UP)
			model_camera.current = true
		character_model = model_scene.get_node_or_null("Model") as Node3D
		character_model_position = character_model.position
		character_animation = character_model.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if character_animation:
			for animation_name in ["Idle", "Walk", "Attack"]:
				var animation: Animation = character_animation.get_animation(animation_name)
				if animation:
					animation.loop_mode = Animation.LOOP_LINEAR
		if key == "soldier_flamethrower":
			character_model = model_scene.get_node_or_null("Model/Soldier_Root") as Node3D
			character_model_position = character_model.position
			for part_name in [
				"UpperLeg_L", "UpperLeg_R", "LowerLeg_L", "LowerLeg_R",
				"KneePad_L", "KneePad_R", "Boot_L", "Boot_R", "Torso",
				"Head", "Flamethrower_Root", "Hand_L", "Hand_R",
			]:
				var part := character_model.get_node_or_null(part_name) as Node3D
				if part:
					animated_parts[part_name] = {"node": part, "transform": part.transform}
		character_sprite = Sprite2D.new()
		character_sprite.texture = viewport.get_texture()
		character_sprite.flip_h = side == "player"
		character_sprite.position = Vector2(0.0, -31.0)
		character_sprite.scale = Vector2(0.46, 0.46) if key == "soldier_flamethrower" else Vector2(0.38, 0.38)
		add_child(character_sprite)
	bg_bar = ColorRect.new()
	add_child(bg_bar)
	fill_bar = ColorRect.new()
	add_child(fill_bar)
	var bar_w: float = _bar_w()
	bg_bar.size = Vector2(bar_w + 2.0, 5.0)
	bg_bar.color = Color(0.0, 0.0, 0.0, 0.6)
	fill_bar.size = Vector2(bar_w, 3.0)
	fill_bar.color = Color(0.3, 0.9, 0.2)


func _setup_broadsword_2d() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var clip_frames: Dictionary[String, int] = {
		"Walk": 6,
		"Attack": 7,
		"Death": 8,
	}
	for animation_name: String in clip_frames:
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, 7.0)
		frames.set_animation_loop(animation_name, animation_name != "Death")
		var file_prefix: String = animation_name.to_lower()
		for frame_idx: int in range(clip_frames[animation_name]):
			var texture_path: String = "res://assets/sprites/broadsword_2d/%s_%02d.png" % [file_prefix, frame_idx]
			frames.add_frame(animation_name, load(texture_path) as Texture2D)
	character_2d_sprite = AnimatedSprite2D.new()
	character_2d_sprite.sprite_frames = frames
	character_2d_sprite.animation = "Walk"
	character_2d_sprite.flip_h = side == "player"
	character_2d_sprite.position = Vector2(0.0, -47.0)
	character_2d_sprite.scale = Vector2(0.43, 0.43)
	add_child(character_2d_sprite)
	character_2d_sprite.play()


func update_visuals(dt: float, _time_sec: float) -> void:
	if not alive:
		return
	phase += dt * 10.0
	if hit_flash > 0.0:
		hit_flash -= dt
	if dying:
		death_timer -= dt
		if death_timer <= 0.0:
			alive = false
			return
	if character_2d_sprite:
		character_2d_sprite.position = Vector2(0.0, -47.0)
		character_2d_sprite.modulate = Color.WHITE if hit_flash <= 0.0 else Color(1.0, 0.72, 0.45)
		var next_animation: String = "Death" if dying else "Walk" if state == "walk" else "Attack"
		if next_animation != character_2d_sprite.animation:
			character_2d_sprite.play(next_animation)
	if character_sprite:
		character_sprite.position = Vector2(0.0, -31.0)
		character_sprite.rotation = 0.0
		character_sprite.modulate = Color.WHITE if hit_flash <= 0.0 else Color(1.0, 0.72, 0.45)
		if character_animation:
			var next_animation: String = "Death" if dying else "Walk" if state == "walk" else "Attack"
			if next_animation != character_animation_name:
				character_animation.play(next_animation, 0.12)
				character_animation_name = next_animation
		elif character_model:
			var bob: float = -abs(sin(phase)) * 2.5 if state == "walk" else 0.0
			character_model.position = character_model_position + Vector3(0.0, bob * 0.006, 0.0)
			character_model.rotation = Vector3.ZERO
			_animate_character_parts()
	queue_redraw()


func _animate_character_parts() -> void:
	for part_data: Dictionary in animated_parts.values():
		var part: Node3D = part_data["node"]
		part.transform = part_data["transform"]

	var upper_l: Node3D = animated_parts["UpperLeg_L"]["node"]
	var upper_r: Node3D = animated_parts["UpperLeg_R"]["node"]
	var lower_l: Node3D = animated_parts["LowerLeg_L"]["node"]
	var lower_r: Node3D = animated_parts["LowerLeg_R"]["node"]
	var knee_l: Node3D = animated_parts["KneePad_L"]["node"]
	var knee_r: Node3D = animated_parts["KneePad_R"]["node"]
	var boot_l: Node3D = animated_parts["Boot_L"]["node"]
	var boot_r: Node3D = animated_parts["Boot_R"]["node"]
	var torso: Node3D = animated_parts["Torso"]["node"]
	var head: Node3D = animated_parts["Head"]["node"]
	var weapon: Node3D = animated_parts["Flamethrower_Root"]["node"]
	var hand_l: Node3D = animated_parts["Hand_L"]["node"]
	var hand_r: Node3D = animated_parts["Hand_R"]["node"]

	if state == "walk":
		var left_stride: float = sin(phase)
		var right_stride: float = -left_stride
		var left_lift: float = max(0.0, left_stride)
		var right_lift: float = max(0.0, right_stride)

		upper_l.rotation.x += left_stride * 0.42
		upper_r.rotation.x += right_stride * 0.42
		lower_l.rotation.x += left_stride * 0.18 + left_lift * 0.34
		lower_r.rotation.x += right_stride * 0.18 + right_lift * 0.34

		lower_l.position += Vector3(0.0, left_lift * 0.06, left_stride * 0.10)
		lower_r.position += Vector3(0.0, right_lift * 0.06, right_stride * 0.10)
		knee_l.position += Vector3(0.0, left_lift * 0.05, left_stride * 0.08)
		knee_r.position += Vector3(0.0, right_lift * 0.05, right_stride * 0.08)
		boot_l.position += Vector3(0.0, left_lift * 0.13, left_stride * 0.18)
		boot_r.position += Vector3(0.0, right_lift * 0.13, right_stride * 0.18)
		boot_l.rotation.x += left_stride * 0.20
		boot_r.rotation.x += right_stride * 0.20

		var counter_sway: float = sin(phase) * 0.035
		torso.rotation.z += counter_sway
		head.rotation.z -= counter_sway * 0.55
		weapon.rotation.z += counter_sway * 0.65
		hand_l.rotation.z += counter_sway * 0.65
		hand_r.rotation.z += counter_sway * 0.65
	else:
		var recoil: float = (sin(phase * 2.0) + 1.0) * 0.5
		var recoil_offset := Vector3(0.0, recoil * 0.018, recoil * 0.075)
		weapon.position += recoil_offset
		hand_l.position += recoil_offset
		hand_r.position += recoil_offset
		weapon.rotation.x -= recoil * 0.045
		hand_l.rotation.x -= recoil * 0.045
		hand_r.rotation.x -= recoil * 0.045
		torso.rotation.x += recoil * 0.025
		upper_l.rotation.z -= 0.06
		upper_r.rotation.z += 0.06
		boot_l.position.x -= 0.04
		boot_r.position.x += 0.04


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
	if character_sprite or character_2d_sprite:
		_draw_hp_bar(s)
		return
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
	if dying:
		return
	hp = max(0.0, hp - amount)
	hit_flash = 0.12
	if hp <= 0.0:
		dying = true
		death_timer = 1.25
		state = "death"
