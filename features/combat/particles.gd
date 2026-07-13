class_name ParticleField
extends Node2D

var particles: Array = []


func spawn(x: float, y: float, color: Color, count: int = 6, spread: float = 4.0) -> void:
	for i in count:
		particles.append({
			"x": x + randf_range(-spread, spread),
			"y": y + randf_range(-spread, spread),
			"vx": randf_range(-2.0, 2.0),
			"vy": -randf() * 3.0 - 1.0,
			"life": randf_range(0.25, 0.5),
			"max_life": 0.5,
			"color": color,
			"size": randf_range(1.5, 4.0),
		})


func spawn_flame(origin: Vector2, facing: float, count: int = 2) -> void:
	for i in count:
		var life := randf_range(0.18, 0.34)
		particles.append({
			"x": origin.x,
			"y": origin.y + randf_range(-2.5, 2.5),
			"vx": randf_range(105.0, 175.0) * facing,
			"vy": randf_range(-24.0, 18.0),
			"life": life,
			"max_life": life,
			"color": Color(1.0, randf_range(0.22, 0.72), 0.04),
			"size": randf_range(2.5, 5.5),
			"flame": true,
		})


func update_particles(dt: float) -> void:
	var keep: Array = []
	for p in particles:
		if bool(p.get("flame", false)):
			p["x"] = float(p["x"]) + float(p["vx"]) * dt
			p["y"] = float(p["y"]) + float(p["vy"]) * dt
			p["vy"] = float(p["vy"]) - 18.0 * dt
		else:
			p["x"] = float(p["x"]) + float(p["vx"])
			p["y"] = float(p["y"]) + float(p["vy"])
			p["vy"] = float(p["vy"]) + 0.12
		p["life"] = float(p["life"]) - dt
		if float(p["life"]) > 0.0:
			keep.append(p)
	particles = keep
	queue_redraw()


func _draw() -> void:
	for p in particles:
		var alpha: float = max(0.0, float(p["life"]) / float(p["max_life"]))
		var col: Color = p["color"]
		col.a = alpha
		draw_circle(Vector2(float(p["x"]), float(p["y"])), float(p["size"]) * (0.3 + 0.7 * alpha), col)
