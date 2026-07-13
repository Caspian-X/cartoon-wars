class_name CombatSystem
extends Node

const GROUND_Y := 634.0
const LANE_MIN := 123.6
const LANE_LEN := 1032.8
const CROSSBOW_RANGE := 0.75

var troops: Array[Troop] = []
var projectiles: Array[Projectile] = []
var _troop_layer: Node2D
var _projectile_layer: Node2D
var _particles: ParticleField

func setup(troop_layer: Node2D, projectile_layer: Node2D, particles: ParticleField) -> void:
	_troop_layer = troop_layer
	_projectile_layer = projectile_layer
	_particles = particles

func reset() -> void:
	for troop in troops:
		if is_instance_valid(troop): troop.queue_free()
	for projectile in projectiles:
		if is_instance_valid(projectile): projectile.queue_free()
	troops.clear()
	projectiles.clear()
	_particles.particles.clear()

func spawn_troop(side: String, definition: UnitDefinition) -> Troop:
	var troop := Troop.new()
	troop.setup(side, definition)
	_troop_layer.add_child(troop)
	troops.append(troop)
	return troop

func spawn_bolt(start: Vector2, angle: float, side: String, damage: float) -> void:
	var projectile := Projectile.new()
	projectile.setup(start, Vector2.ZERO, null, damage, "bolt", 0.0, angle, side)
	_projectile_layer.add_child(projectile)
	projectiles.append(projectile)

func update(dt: float, time_sec: float) -> Vector2:
	var base_damage := Vector2.ZERO
	for troop in troops:
		if not is_instance_valid(troop) or not troop.alive or troop.dying: continue
		var definition := troop.definition
		var direction := 1.0 if troop.side == "player" else -1.0
		var distance_to_base := (1.0 - troop.frac) if troop.side == "player" else troop.frac
		var target := nearest_enemy(troop)
		var target_is_base := false
		if target == null or abs(target.frac - troop.frac) > definition.attack_range:
			target = null
			target_is_base = distance_to_base <= definition.attack_range
		if target or target_is_base:
			troop.state = "attack"
			if definition.weapon == "flame": _spawn_flame_particles(troop)
			troop.atk_timer -= dt
			if troop.atk_timer <= 0.0:
				troop.atk_timer = definition.attack_interval
				if target:
					_attack_target(troop, target)
				elif troop.side == "player":
					base_damage.y += definition.damage
				else:
					base_damage.x += definition.damage
		else:
			troop.state = "walk"
			troop.phase += dt * 8.0
			troop.frac = clamp(troop.frac + direction * definition.speed * dt, 0.0, 1.0)
		if troop.hit_flash > 0.0: troop.hit_flash -= dt
	for troop in troops:
		if is_instance_valid(troop):
			troop.position = Vector2(LANE_MIN + troop.frac * LANE_LEN, GROUND_Y + troop.y_jitter * 0.25)
			troop.update_visuals(dt, time_sec)
	_update_projectiles(dt)
	_particles.update_particles(dt)
	var living: Array[Troop] = []
	for troop in troops:
		if is_instance_valid(troop) and troop.alive: living.append(troop)
		elif is_instance_valid(troop): troop.queue_free()
	troops = living
	return base_damage

func _attack_target(attacker: Troop, target: Troop) -> void:
	match attacker.definition.weapon:
		"bow", "magic": _spawn_projectile(attacker, target)
		"flame": _damage_flame_area(attacker, target)
		_:
			target.take_damage(attacker.definition.damage)
			_spawn_hit_particles(target, false)

func _spawn_projectile(attacker: Troop, target: Troop) -> void:
	var definition := attacker.definition
	var kind := "arrow" if definition.weapon == "bow" else "magic"
	var projectile := Projectile.new()
	projectile.setup(
		Vector2(attacker.position.x, attacker.position.y - 20.0 * definition.visual_scale),
		Vector2(target.position.x, target.position.y - 20.0 * target.definition.visual_scale),
		target, definition.damage, kind, 1.0 / (0.35 if kind == "arrow" else 0.45))
	_projectile_layer.add_child(projectile)
	projectiles.append(projectile)

func _update_projectiles(dt: float) -> void:
	var remaining: Array[Projectile] = []
	for projectile in projectiles:
		if not is_instance_valid(projectile): continue
		var reached := projectile.update_progress(dt)
		projectile.queue_redraw()
		if projectile.kind == "bolt" and not reached:
			if projectile.physics_pos.y >= GROUND_Y:
				reached = true
			else:
				var hit := nearest_troop_in_range(projectile.physics_pos, 20.0, projectile.side)
				if hit and ((hit.frac <= CROSSBOW_RANGE) if projectile.side == "player" else (hit.frac >= 1.0 - CROSSBOW_RANGE)):
					hit.take_damage(projectile.damage)
					_spawn_hit_particles(hit, true, projectile.kind)
					reached = true
		if reached:
			if projectile.kind != "bolt" and is_instance_valid(projectile.target) and projectile.target.alive:
				projectile.target.take_damage(projectile.damage)
				_spawn_hit_particles(projectile.target, true, projectile.kind)
			projectile.queue_free()
		else: remaining.append(projectile)
	projectiles = remaining

func _damage_flame_area(attacker: Troop, primary: Troop) -> void:
	for target in troops:
		if not is_instance_valid(target) or not target.alive or target.dying or target.side == attacker.side: continue
		if abs(target.frac - primary.frac) <= attacker.definition.aoe_range:
			target.take_damage(attacker.definition.damage)
			_spawn_hit_particles(target, true, "flame")

func _spawn_hit_particles(troop: Troop, from_projectile: bool, _kind := "arrow") -> void:
	var color := Color(0.31, 0.83, 0.97) if troop.side == "player" else Color(1.0, 0.44, 0.26)
	if from_projectile: _particles.spawn(troop.position.x, troop.position.y - 20.0, color, 6, 6.0)
	else: _particles.spawn(troop.position.x, troop.position.y - 16.0, Color(1.0, 0.84, 0.31), 4, 8.0)

func _spawn_flame_particles(troop: Troop) -> void:
	var facing := 1.0 if troop.side == "player" else -1.0
	_particles.spawn_flame(troop.position + Vector2(24.0 * facing, -25.0), facing, 2)

func nearest_enemy(troop: Troop) -> Troop:
	var best: Troop
	var best_distance := INF
	for other in troops:
		if not is_instance_valid(other) or not other.alive or other.dying or other.side == troop.side: continue
		var distance: float = abs(other.frac - troop.frac)
		var ahead := (troop.side == "player" and other.frac >= troop.frac) or (troop.side == "enemy" and other.frac <= troop.frac)
		if ahead and distance < best_distance: best_distance = distance; best = other
	return best

func nearest_troop_in_range(position: Vector2, radius: float, side: String) -> Troop:
	var best: Troop
	var best_distance := radius
	for troop in troops:
		if not is_instance_valid(troop) or not troop.alive or troop.dying or troop.side == side: continue
		var distance := position.distance_to(troop.position)
		if distance < best_distance: best_distance = distance; best = troop
	return best

func nearest_crossbow_target(side: String) -> Troop:
	var best: Troop
	var best_distance := INF
	for troop in troops:
		if not is_instance_valid(troop) or not troop.alive or troop.dying or troop.side == side: continue
		if side == "player" and troop.frac > CROSSBOW_RANGE: continue
		if side == "enemy" and troop.frac < 1.0 - CROSSBOW_RANGE: continue
		var distance := troop.frac if side == "player" else 1.0 - troop.frac
		if distance < best_distance: best_distance = distance; best = troop
	return best
