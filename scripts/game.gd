class_name Game
extends Node2D

const VIEW_W := 1280.0
const VIEW_H := 720.0
const GROUND_Y := 634.0
const BASE_L_X := 89.6
const BASE_R_X := 1190.4
const LANE_MIN := BASE_L_X + 34.0
const LANE_MAX := BASE_R_X - 34.0
const LANE_LEN := LANE_MAX - LANE_MIN

const BASE_MAX_HP := 180.0
const MANA_MAX := 10.0
const MANA_REGEN := 1.0 / 1.8
const AI_INTERVAL := 1.2
const CROSSBOW_RANGE := 0.75
const CROSSBOW_DMG := 7.0

const STATE_MENU := "menu"
const STATE_LEVEL_SELECT := "level_select"
const STATE_PLAYING := "playing"
const STATE_OVER := "over"

const TROOP_TYPES: Array = [
	{
		"key": "spearman", "name": "Spearman", "cost": 2, "hp": 35.0, "dmg": 6.0,
		"atk_interval": 0.9, "range": 0.018, "speed": 0.11, "weapon": "melee",
		"scale": 0.13, "foot_offset": 0.93,
		"sprite_frames": [
			"res://assets/sprites/spearman_frame_1.png",
			"res://assets/sprites/spearman_frame_2.png",
			"res://assets/sprites/spearman_frame_3.png",
			"res://assets/sprites/spearman_frame_4.png",
		],
		"anim_fps": 8.0,
	},
	{
		"key": "bowman", "name": "Bowman", "cost": 4, "hp": 22.0, "dmg": 9.0,
		"atk_interval": 1.1, "range": 0.16, "speed": 0.09, "weapon": "bow",
		"scale": 0.13, "foot_offset": 0.93,
		"sprite_path": "res://assets/sprites/bowman.png",
	},
	{
		"key": "wizard", "name": "Wizard", "cost": 6, "hp": 30.0, "dmg": 12.0,
		"atk_interval": 1.3, "range": 0.155, "speed": 0.085, "weapon": "magic",
		"scale": 0.13, "foot_offset": 0.93,
		"sprite_path": "res://assets/sprites/wizard.png",
	},
	{
		"key": "broadsword", "name": "Knight", "cost": 8, "hp": 120.0, "dmg": 18.0,
		"atk_interval": 1.4, "range": 0.024, "speed": 0.05, "weapon": "melee",
		"scale": 0.17, "foot_offset": 0.93,
		"sprite_path": "res://assets/sprites/broadsword.png",
	},
]

const ENEMY_TROOP_TYPES: Array = [
	{
		"key": "golem", "name": "Golem", "cost": 4, "hp": 80.0, "dmg": 10.0,
		"atk_interval": 1.2, "range": 0.022, "speed": 0.06, "weapon": "melee",
		"scale": 0.17, "foot_offset": 0.93,
	},
	{
		"key": "skeleton", "name": "Skeleton", "cost": 3, "hp": 18.0, "dmg": 7.0,
		"atk_interval": 1.0, "range": 0.14, "speed": 0.10, "weapon": "bow",
		"scale": 0.13, "foot_offset": 0.93,
	},
	{
		"key": "imp", "name": "Imp", "cost": 5, "hp": 20.0, "dmg": 10.0,
		"atk_interval": 1.0, "range": 0.14, "speed": 0.12, "weapon": "magic",
		"scale": 0.10, "foot_offset": 0.93,
	},
]

const LEVELS: Array = [
	{
		"id": 1, "name": "The Beginning",
		"desc": "Repel the enemy's monstrous forces!",
		"enemy_types": [0, 1, 2],
	},
]

var state: String = STATE_MENU
var player_hp: float = BASE_MAX_HP
var enemy_hp: float = BASE_MAX_HP
var player_mana: float = 5.0
var ai_mana: float = 5.0
var troops: Array[Troop] = []
var projectiles: Array[Projectile] = []
var ai_timer: float = 0.0
var time_sec: float = 0.0
var current_level_data: Dictionary = LEVELS[0]
var current_enemy_types: Array = LEVELS[0]["enemy_types"]

var _player_base: Base
var _enemy_base: Base
var _troop_layer: Node2D
var _proj_layer: Node2D
var _particles: ParticleField
var _hud: HUD


func _ready() -> void:
	_player_base = Base.new()
	_player_base.setup("player", BASE_MAX_HP)
	_player_base.position = Vector2(BASE_L_X, GROUND_Y)
	_player_base.bolt_fired.connect(_on_bolt_fired)
	add_child(_player_base)
	_enemy_base = Base.new()
	_enemy_base.setup("enemy", BASE_MAX_HP)
	_enemy_base.position = Vector2(BASE_R_X, GROUND_Y)
	_enemy_base.bolt_fired.connect(_on_bolt_fired)
	add_child(_enemy_base)

	_troop_layer = Node2D.new()
	_troop_layer.name = "Troops"
	add_child(_troop_layer)
	_proj_layer = Node2D.new()
	_proj_layer.name = "Projectiles"
	add_child(_proj_layer)
	_particles = ParticleField.new()
	_particles.name = "Particles"
	add_child(_particles)

	_hud = HUD.new()
	_hud.set_troop_data(TROOP_TYPES)
	_hud.spawn_requested.connect(_on_spawn_requested)
	_hud.aim_changed.connect(_on_aim_changed)
	_hud.start_requested.connect(start_game)
	_hud.menu_requested.connect(_show_menu)
	_hud.level_select_requested.connect(_on_level_select_requested)
	_hud.level_selected.connect(_on_level_selected)
	add_child(_hud)

	_reset_round()
	_show_menu()


func _show_menu() -> void:
	state = STATE_MENU
	_reset_round()
	_hud.show_menu()
	_hud.hide_level_select()


func _on_level_select_requested() -> void:
	state = STATE_LEVEL_SELECT
	_hud.show_level_select(LEVELS)


func _on_level_selected(level_id: int) -> void:
	_hud.hide_level_select()
	start_level(level_id)


func start_level(level_id: int) -> void:
	for lvl in LEVELS:
		if lvl["id"] == level_id:
			current_level_data = lvl
			current_enemy_types = lvl["enemy_types"]
			break
	start_game()


func _reset_round() -> void:
	player_hp = BASE_MAX_HP
	enemy_hp = BASE_MAX_HP
	player_mana = 5.0
	ai_mana = 5.0
	ai_timer = 0.0
	for t in troops:
		if is_instance_valid(t):
			t.queue_free()
	troops.clear()
	for p in projectiles:
		if is_instance_valid(p):
			p.queue_free()
	projectiles.clear()
	_particles.particles.clear()
	if _player_base:
		_player_base.hp = BASE_MAX_HP
		_player_base.crossbow_angle = 0.0
		_player_base.fire_timer = 0.6
	if _enemy_base:
		_enemy_base.hp = BASE_MAX_HP
		_enemy_base.crossbow_angle = 0.0
		_enemy_base.fire_timer = 0.8
	if _hud:
		_hud.update_hp(player_hp, enemy_hp, BASE_MAX_HP)
		_hud.update_mana(player_mana, MANA_MAX)
		_hud.update_troop_buttons(player_mana)


func start_game() -> void:
	_reset_round()
	state = STATE_PLAYING
	_hud.hide_menu()
	_hud.hide_level_select()
	_hud.hide_result()
	_hud.set_gameplay_visible(true)


func _process(dt: float) -> void:
	time_sec += dt
	queue_redraw()
	if state != STATE_PLAYING:
		return

	player_mana = min(MANA_MAX, player_mana + MANA_REGEN * dt)
	ai_mana = min(MANA_MAX, ai_mana + MANA_REGEN * dt)
	_ai_decision(dt)

	for troop in troops:
		if not is_instance_valid(troop) or not troop.alive:
			continue
		var d: Dictionary = troop.data
		var dir: float = 1.0 if troop.side == "player" else -1.0
		var dist_to_base: float = (1.0 - troop.frac) if troop.side == "player" else troop.frac
		var foe: Troop = _nearest_enemy(troop)
		var target: Troop = null
		var target_is_base := false
		if foe != null and abs(foe.frac - troop.frac) <= float(d.get("range", 0.02)):
			target = foe
		elif dist_to_base <= float(d.get("range", 0.02)):
			target_is_base = true

		if target or target_is_base:
			troop.state = "attack"
			troop.atk_timer -= dt
			if troop.atk_timer <= 0.0:
				troop.atk_timer = float(d.get("atk_interval", 1.0))
				if target:
					var weapon: String = String(d.get("weapon", "melee"))
					if weapon == "bow" or weapon == "magic":
						_spawn_projectile(troop, target, d)
					else:
						target.take_damage(float(d.get("dmg", 5.0)))
						_spawn_hit_particles(target, false)
				else:
					if troop.side == "player":
						enemy_hp = max(0.0, enemy_hp - float(d.get("dmg", 5.0)))
						_enemy_base.take_damage(float(d.get("dmg", 5.0)))
					else:
						player_hp = max(0.0, player_hp - float(d.get("dmg", 5.0)))
						_player_base.take_damage(float(d.get("dmg", 5.0)))
		else:
			troop.state = "walk"
			troop.phase += dt * 8.0
			troop.frac = clamp(troop.frac + dir * float(d.get("speed", 0.1)) * dt, 0.0, 1.0)

		if troop.hit_flash > 0.0:
			troop.hit_flash -= dt

	for troop in troops:
		if is_instance_valid(troop):
			troop.position = Vector2(LANE_MIN + troop.frac * LANE_LEN, GROUND_Y + troop.y_jitter * 0.25)
			troop.update_visuals(dt, time_sec)

	var p_target: Troop = _nearest_crossbow_target("player")
	_player_base.update_crossbow(dt, p_target, GROUND_Y, _cb_pivot(_player_base))
	_player_base.queue_redraw()
	_enemy_base.queue_redraw()

	var keep_proj: Array[Projectile] = []
	for p in projectiles:
		if not is_instance_valid(p):
			continue
		var reached: bool = p.update_progress(dt)
		p.queue_redraw()
		if p.kind == "bolt" and not reached:
			if p.physics_pos.y >= GROUND_Y:
				reached = true
			else:
				var hit := _nearest_troop_in_range(p.physics_pos, 20.0, p.side)
				if is_instance_valid(hit):
					var hit_in_range: bool = (hit.frac <= CROSSBOW_RANGE) if p.side == "player" else (hit.frac >= 1.0 - CROSSBOW_RANGE)
					if hit_in_range:
						hit.take_damage(p.damage)
						_spawn_hit_particles(hit, true, p.kind)
						reached = true
		if reached:
			if p.kind != "bolt" and is_instance_valid(p.target) and p.target.alive:
				p.target.take_damage(p.damage)
				_spawn_hit_particles(p.target, true, p.kind)
			p.queue_free()
		else:
			keep_proj.append(p)
	projectiles = keep_proj

	_particles.update_particles(dt)

	var keep_troops: Array[Troop] = []
	for t in troops:
		if is_instance_valid(t) and t.alive:
			keep_troops.append(t)
		else:
			if is_instance_valid(t):
				t.queue_free()
	troops = keep_troops

	_hud.update_hp(player_hp, enemy_hp, BASE_MAX_HP)
	_hud.update_mana(player_mana, MANA_MAX)
	_hud.update_troop_buttons(player_mana)

	if player_hp <= 0.0 or enemy_hp <= 0.0:
		state = STATE_OVER
		_hud.show_result(enemy_hp <= 0.0)


func _cb_pivot(b: Base) -> Vector2:
	return Vector2(b.position.x, b.position.y - 100.0)


func _spawn_projectile(troop: Troop, target: Troop, d: Dictionary) -> void:
	var p := Projectile.new()
	var start := Vector2(troop.position.x, troop.position.y - 20.0 * float(d.get("scale", 0.13)))
	var end := Vector2(target.position.x, target.position.y - 20.0 * float(target.data.get("scale", 0.13)))
	var kind: String = "arrow" if String(d.get("weapon", "bow")) == "bow" else "magic"
	var spd: float = 1.0 / (0.35 if kind == "arrow" else 0.45)
	p.setup(start, end, target, float(d.get("dmg", 9.0)), kind, spd)
	_proj_layer.add_child(p)
	projectiles.append(p)


func _on_bolt_fired(start_pos: Vector2, angle: float, side: String) -> void:
	var p := Projectile.new()
	p.setup(start_pos, Vector2.ZERO, null, CROSSBOW_DMG, "bolt", 0.0, angle, side)
	_proj_layer.add_child(p)
	projectiles.append(p)


func _spawn_hit_particles(troop: Troop, from_projectile: bool, _kind: String = "arrow") -> void:
	var col: Color = Color(0.31, 0.83, 0.97) if troop.side == "player" else Color(1.0, 0.44, 0.26)
	if from_projectile:
		_particles.spawn(troop.position.x, troop.position.y - 20.0, col, 6, 6.0)
	else:
		_particles.spawn(troop.position.x, troop.position.y - 16.0, Color(1.0, 0.84, 0.31), 4, 8.0)


func _nearest_enemy(troop: Troop) -> Troop:
	var best: Troop = null
	var best_dist: float = INF
	for o in troops:
		if not is_instance_valid(o) or not o.alive or o.side == troop.side:
			continue
		var dist: float = abs(o.frac - troop.frac)
		var ahead: bool = (troop.side == "player" and o.frac >= troop.frac) or (troop.side == "enemy" and o.frac <= troop.frac)
		if ahead and dist < best_dist:
			best_dist = dist
			best = o
	return best


func _nearest_troop_in_range(pos: Vector2, radius: float, side: String) -> Troop:
	var best: Troop = null
	var best_dist: float = radius
	for o in troops:
		if not is_instance_valid(o) or not o.alive or o.side == side:
			continue
		var dist: float = pos.distance_to(o.position)
		if dist < best_dist:
			best_dist = dist
			best = o
	return best


func _nearest_crossbow_target(side: String) -> Troop:
	var best: Troop = null
	var best_dist: float = INF
	for o in troops:
		if not is_instance_valid(o) or not o.alive or o.side == side:
			continue
		if side == "player" and o.frac > CROSSBOW_RANGE:
			continue
		if side == "enemy" and o.frac < 1.0 - CROSSBOW_RANGE:
			continue
		var dd: float = o.frac if side == "player" else (1.0 - o.frac)
		if dd < best_dist:
			best_dist = dd
			best = o
	return best


func _ai_decision(dt: float) -> void:
	ai_timer += dt
	if ai_timer < AI_INTERVAL:
		return
	ai_timer = 0.0
	var affordable: Array[int] = []
	for i in current_enemy_types.size():
		var type_idx: int = current_enemy_types[i]
		if float(ENEMY_TROOP_TYPES[type_idx].get("cost", 0)) <= ai_mana:
			affordable.append(i)
	if affordable.is_empty():
		return
	if randf() > 0.72:
		return
	var weights: Array[float] = []
	for j in affordable:
		var cost: float = float(ENEMY_TROOP_TYPES[current_enemy_types[j]].get("cost", 0))
		weights.append(3.0 if cost <= 4.0 else 1.0)
	var total: float = 0.0
	for w in weights:
		total += float(w)
	var r: float = randf() * total
	var pick: int = affordable[0]
	for i in affordable.size():
		if r < float(weights[i]):
			pick = affordable[i]
			break
		r -= float(weights[i])
	var chosen_type: int = current_enemy_types[pick]
	ai_mana -= float(ENEMY_TROOP_TYPES[chosen_type].get("cost", 0))
	_spawn_enemy_troop(chosen_type)


func _spawn_troop(side: String, type_idx: int) -> Troop:
	var t := Troop.new()
	t.setup(side, type_idx, TROOP_TYPES[type_idx])
	_troop_layer.add_child(t)
	troops.append(t)
	return t


func _spawn_enemy_troop(type_idx: int) -> Troop:
	var t := Troop.new()
	t.setup("enemy", type_idx, ENEMY_TROOP_TYPES[type_idx])
	_troop_layer.add_child(t)
	troops.append(t)
	return t


func try_spawn(type_idx: int) -> void:
	if state != STATE_PLAYING:
		return
	var cost: float = float(TROOP_TYPES[type_idx].get("cost", 0))
	if player_mana < cost:
		return
	player_mana -= cost
	_spawn_troop("player", type_idx)


func _on_spawn_requested(idx: int) -> void:
	try_spawn(idx)


func _on_aim_changed(delta: float) -> void:
	if state != STATE_PLAYING:
		return
	_player_base.crossbow_angle = clamp(_player_base.crossbow_angle + delta, -0.4, 0.8)


func _unhandled_input(event: InputEvent) -> void:
	if state == STATE_MENU:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
			_on_level_select_requested()
		return
	if state == STATE_LEVEL_SELECT:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: try_spawn(0)
			KEY_2: try_spawn(1)
			KEY_3: try_spawn(2)
			KEY_4: try_spawn(3)
			KEY_UP: _on_aim_changed(-0.05)
			KEY_DOWN: _on_aim_changed(0.05)
			KEY_R: start_game()


func _draw() -> void:
	var sky_steps := 60
	var sky_grad := Gradient.new()
	sky_grad.set_color(0, Color(0.25, 0.42, 0.72))
	sky_grad.set_offset(0, 0.0)
	sky_grad.set_color(1, Color(0.88, 0.96, 1.0))
	sky_grad.set_offset(1, 1.0)
	sky_grad.add_point(0.3, Color(0.42, 0.65, 0.92))
	sky_grad.add_point(0.6, Color(0.65, 0.85, 0.98))
	for i in sky_steps:
		var t: float = float(i) / float(sky_steps)
		draw_rect(Rect2(0.0, t * GROUND_Y, VIEW_W, GROUND_Y / float(sky_steps) + 1.0), sky_grad.sample(t))

	_draw_sun()
	_draw_clouds()
	_draw_mountains()
	_draw_hills()

	var grass_steps := 40
	for i in grass_steps:
		var t: float = float(i) / float(grass_steps)
		var c: Color = Color(0.48, 0.74, 0.32).lerp(Color(0.30, 0.58, 0.20), t)
		draw_rect(Rect2(0.0, GROUND_Y + t * (VIEW_H - GROUND_Y), VIEW_W, (VIEW_H - GROUND_Y) / float(grass_steps) + 1.0), c)

	# Dirt path in the lane
	var path_top: float = GROUND_Y + 2.0
	var path_bot: float = GROUND_Y + 18.0
	var path_grad_steps: int = 8
	for i in path_grad_steps:
		var t: float = float(i) / float(path_grad_steps)
		var path_c: Color = Color(0.62, 0.52, 0.35).lerp(Color(0.45, 0.36, 0.24), t)
		var alpha: float = 0.50 * (1.0 - t * 0.5)
		draw_rect(Rect2(LANE_MIN - 20.0, path_top + t * (path_bot - path_top), LANE_LEN + 40.0, (path_bot - path_top) / float(path_grad_steps) + 1.0), Color(path_c.r, path_c.g, path_c.b, alpha))

	# Path edges
	draw_line(Vector2(LANE_MIN - 20.0, path_top), Vector2(LANE_MIN - 20.0, path_bot), Color(0.40, 0.32, 0.20, 0.35), 2.0)
	draw_line(Vector2(LANE_MAX + 20.0, path_top), Vector2(LANE_MAX + 20.0, path_bot), Color(0.40, 0.32, 0.20, 0.35), 2.0)

	# Atmospheric haze at horizon
	draw_rect(Rect2(0.0, GROUND_Y - 8.0, VIEW_W, 12.0), Color(0.80, 0.90, 1.0, 0.15))

	draw_line(Vector2(0.0, GROUND_Y), Vector2(VIEW_W, GROUND_Y), Color(0.18, 0.35, 0.12, 0.65), 3.0)
	_draw_grass_tufts()
	_draw_ground_details()


func _draw_sun() -> void:
	var sun_pos := Vector2(VIEW_W * 0.88, VIEW_H * 0.12)
	# Outer glow
	draw_circle(sun_pos, 56.0, Color(1.0, 0.95, 0.75, 0.05))
	draw_circle(sun_pos, 44.0, Color(1.0, 0.95, 0.75, 0.08))
	draw_circle(sun_pos, 32.0, Color(1.0, 0.95, 0.75, 0.12))
	draw_circle(sun_pos, 24.0, Color(1.0, 0.96, 0.80, 0.25))
	# Core
	draw_circle(sun_pos, 16.0, Color(1.0, 0.98, 0.86, 0.9))
	draw_circle(sun_pos, 10.0, Color(1.0, 1.0, 0.95, 0.95))


func _draw_clouds() -> void:
	_draw_cloud(Vector2(VIEW_W * 0.12, VIEW_H * 0.14), 1.2)
	_draw_cloud(Vector2(VIEW_W * 0.35, VIEW_H * 0.08), 0.9)
	_draw_cloud(Vector2(VIEW_W * 0.55, VIEW_H * 0.18), 1.0)
	_draw_cloud(Vector2(VIEW_W * 0.78, VIEW_H * 0.10), 0.7)
	_draw_cloud(Vector2(VIEW_W * 0.92, VIEW_H * 0.20), 0.8)


func _draw_cloud(pos: Vector2, s: float) -> void:
	var c := Color(1.0, 1.0, 1.0, 0.85)
	var c_dark := Color(0.92, 0.94, 0.98, 0.50)
	# Puffy cloud using multiple overlapping circles
	draw_circle(pos + Vector2(0.0, 2.0 * s), 20.0 * s, c_dark)
	draw_circle(pos, 18.0 * s, c)
	draw_circle(pos + Vector2(28.0 * s, 4.0 * s), 16.0 * s, c)
	draw_circle(pos + Vector2(-26.0 * s, 6.0 * s), 14.0 * s, c)
	draw_circle(pos + Vector2(-12.0 * s, -6.0 * s), 12.0 * s, c)
	draw_circle(pos + Vector2(16.0 * s, -3.0 * s), 13.0 * s, c)
	draw_circle(pos + Vector2(6.0 * s, -8.0 * s), 10.0 * s, c)
	draw_circle(pos + Vector2(-4.0 * s, 10.0 * s), 9.0 * s, c)
	draw_circle(pos + Vector2(22.0 * s, 10.0 * s), 8.0 * s, c)


func _draw_mountains() -> void:
	var mount_color := Color(0.35, 0.40, 0.52, 0.55)
	var snow_color := Color(0.92, 0.95, 1.0, 0.45)
	var peaks: Array[Array] = [
		[50.0, GROUND_Y, -55.0, -140.0, 60.0],
		[170.0, GROUND_Y, -40.0, -110.0, 80.0],
		[280.0, GROUND_Y, -65.0, -170.0, 65.0],
		[400.0, GROUND_Y, -50.0, -130.0, 90.0],
		[530.0, GROUND_Y, -70.0, -190.0, 75.0],
		[680.0, GROUND_Y, -55.0, -150.0, 85.0],
		[800.0, GROUND_Y, -60.0, -165.0, 70.0],
		[920.0, GROUND_Y, -45.0, -120.0, 80.0],
		[1030.0, GROUND_Y, -65.0, -180.0, 65.0],
		[1160.0, GROUND_Y, -50.0, -140.0, 75.0],
		[1270.0, GROUND_Y, -55.0, -150.0, 60.0],
	]
	for p in peaks:
		var px: float = p[0]
		var py: float = p[1]
		var lx: float = p[2]
		var ly: float = p[3]
		var rx: float = p[4]
		draw_colored_polygon(PackedVector2Array([
			Vector2(px + lx, py), Vector2(px, py + ly), Vector2(px + rx, py)
		]), mount_color)
		draw_colored_polygon(PackedVector2Array([
			Vector2(px + lx * 0.3, py + ly * 0.25),
			Vector2(px, py + ly),
			Vector2(px + rx * 0.3, py + ly * 0.25),
			Vector2(px + lx * 0.15, py + ly * 0.35),
		]), snow_color)

	var hill_color := Color(0.40, 0.55, 0.30, 0.65)
	for h in [[0.0, GROUND_Y, 180.0, -45.0], [150.0, GROUND_Y, 120.0, -35.0],
			  [320.0, GROUND_Y, 150.0, -40.0], [500.0, GROUND_Y, 140.0, -30.0],
			  [670.0, GROUND_Y, 160.0, -50.0], [850.0, GROUND_Y, 130.0, -35.0],
			  [1000.0, GROUND_Y, 170.0, -45.0], [1180.0, GROUND_Y, 140.0, -38.0]]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(h[0] - h[2], h[1]), Vector2(h[0], h[1] + h[3]), Vector2(h[0] + h[2], h[1])
		]), hill_color)


func _draw_hills() -> void:
	var hill := Color(0.45, 0.62, 0.32, 0.40)
	for h in [[-20.0, GROUND_Y, 200.0, -30.0], [250.0, GROUND_Y, 180.0, -25.0],
			  [480.0, GROUND_Y, 220.0, -35.0], [750.0, GROUND_Y, 190.0, -28.0],
			  [980.0, GROUND_Y, 210.0, -32.0], [1200.0, GROUND_Y, 180.0, -25.0]]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(h[0] - h[2], h[1]), Vector2(h[0], h[1] + h[3]), Vector2(h[0] + h[2], h[1])
		]), hill)


func _draw_grass_tufts() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var grass_colors := [Color(0.22, 0.45, 0.14, 0.5), Color(0.18, 0.40, 0.12, 0.45), Color(0.28, 0.50, 0.18, 0.4)]
	for i in range(80):
		var gx: float = rng.randf() * VIEW_W
		var gh: float = 4.0 + rng.randf() * 10.0
		var lean: float = (rng.randf() - 0.5) * 4.0
		var col: Color = grass_colors[i % 3]
		var thick: float = 1.0 + rng.randf() * 1.0
		draw_line(Vector2(gx, GROUND_Y), Vector2(gx + lean, GROUND_Y - gh), col, thick)
		# Second blade
		if rng.randf() > 0.5:
			draw_line(Vector2(gx, GROUND_Y), Vector2(gx + lean * 0.7 + 1.0, GROUND_Y - gh * 0.8), col, thick * 0.7)


func _draw_ground_details() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 123
	# Small rocks
	for i in range(12):
		var rx: float = rng.randf() * VIEW_W
		var ry: float = GROUND_Y + 2.0 + rng.randf() * 8.0
		var rs: float = 2.0 + rng.randf() * 3.0
		var rock_col: Color = Color(0.35 + rng.randf() * 0.1, 0.32 + rng.randf() * 0.08, 0.28 + rng.randf() * 0.05, 0.6)
		draw_circle(Vector2(rx, ry), rs, rock_col)
		draw_circle(Vector2(rx + 1.0, ry - 1.0), rs * 0.6, Color(rock_col.r + 0.05, rock_col.g + 0.05, rock_col.b + 0.05, rock_col.a))
	# Tiny flowers
	for i in range(8):
		var fx: float = rng.randf() * VIEW_W
		var fy: float = GROUND_Y + 1.0 + rng.randf() * 4.0
		var fcol: Color = Color(0.85 + rng.randf() * 0.15, 0.70 + rng.randf() * 0.2, 0.20 + rng.randf() * 0.3, 0.7)
		draw_circle(Vector2(fx, fy), 2.0, fcol)
		draw_line(Vector2(fx, fy), Vector2(fx, fy + 3.0), Color(0.22, 0.45, 0.14, 0.6), 1.0)
