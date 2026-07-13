class_name Battlefield
extends Node2D

const VIEW_W := 1280.0
const VIEW_H := 720.0
const GROUND_Y := 634.0
const LANE_MIN := 123.6
const LANE_MAX := 1156.4
const LANE_LEN := LANE_MAX - LANE_MIN

func _draw() -> void:
	var sky_steps := 60
	var sky_grad := Gradient.new()
	sky_grad.set_color(0, Color(0.25, 0.42, 0.72)); sky_grad.set_offset(0, 0.0)
	sky_grad.set_color(1, Color(0.88, 0.96, 1.0)); sky_grad.set_offset(1, 1.0)
	sky_grad.add_point(0.3, Color(0.42, 0.65, 0.92)); sky_grad.add_point(0.6, Color(0.65, 0.85, 0.98))
	for i in sky_steps:
		var t := float(i) / sky_steps
		draw_rect(Rect2(0.0, t * GROUND_Y, VIEW_W, GROUND_Y / sky_steps + 1.0), sky_grad.sample(t))
	_draw_sun(); _draw_clouds(); _draw_mountains(); _draw_hills()
	var grass_steps := 40
	for i in grass_steps:
		var t := float(i) / grass_steps
		var color := Color(0.48, 0.74, 0.32).lerp(Color(0.30, 0.58, 0.20), t)
		draw_rect(Rect2(0.0, GROUND_Y + t * (VIEW_H - GROUND_Y), VIEW_W, (VIEW_H - GROUND_Y) / grass_steps + 1.0), color)
	var path_top := GROUND_Y + 2.0
	var path_bottom := GROUND_Y + 18.0
	var path_steps := 8
	for i in path_steps:
		var t := float(i) / path_steps
		var color := Color(0.62, 0.52, 0.35).lerp(Color(0.45, 0.36, 0.24), t)
		var alpha := 0.50 * (1.0 - t * 0.5)
		draw_rect(Rect2(LANE_MIN - 20.0, path_top + t * (path_bottom - path_top), LANE_LEN + 40.0, (path_bottom - path_top) / path_steps + 1.0), Color(color.r, color.g, color.b, alpha))
	draw_line(Vector2(LANE_MIN - 20.0, path_top), Vector2(LANE_MIN - 20.0, path_bottom), Color(0.40, 0.32, 0.20, 0.35), 2.0)
	draw_line(Vector2(LANE_MAX + 20.0, path_top), Vector2(LANE_MAX + 20.0, path_bottom), Color(0.40, 0.32, 0.20, 0.35), 2.0)
	draw_rect(Rect2(0.0, GROUND_Y - 8.0, VIEW_W, 12.0), Color(0.80, 0.90, 1.0, 0.15))
	draw_line(Vector2(0.0, GROUND_Y), Vector2(VIEW_W, GROUND_Y), Color(0.18, 0.35, 0.12, 0.65), 3.0)
	_draw_grass_tufts(); _draw_ground_details()

func _draw_sun() -> void:
	var position := Vector2(VIEW_W * 0.88, VIEW_H * 0.12)
	draw_circle(position, 56.0, Color(1.0, 0.95, 0.75, 0.05)); draw_circle(position, 44.0, Color(1.0, 0.95, 0.75, 0.08))
	draw_circle(position, 32.0, Color(1.0, 0.95, 0.75, 0.12)); draw_circle(position, 24.0, Color(1.0, 0.96, 0.80, 0.25))
	draw_circle(position, 16.0, Color(1.0, 0.98, 0.86, 0.9)); draw_circle(position, 10.0, Color(1.0, 1.0, 0.95, 0.95))

func _draw_clouds() -> void:
	_draw_cloud(Vector2(VIEW_W * 0.12, VIEW_H * 0.14), 1.2); _draw_cloud(Vector2(VIEW_W * 0.35, VIEW_H * 0.08), 0.9)
	_draw_cloud(Vector2(VIEW_W * 0.55, VIEW_H * 0.18), 1.0); _draw_cloud(Vector2(VIEW_W * 0.78, VIEW_H * 0.10), 0.7)
	_draw_cloud(Vector2(VIEW_W * 0.92, VIEW_H * 0.20), 0.8)

func _draw_cloud(position: Vector2, scale_factor: float) -> void:
	var color := Color(1.0, 1.0, 1.0, 0.85)
	var dark := Color(0.92, 0.94, 0.98, 0.50)
	draw_circle(position + Vector2(0.0, 2.0 * scale_factor), 20.0 * scale_factor, dark)
	for item in [[Vector2.ZERO, 18.0], [Vector2(28, 4), 16.0], [Vector2(-26, 6), 14.0], [Vector2(-12, -6), 12.0], [Vector2(16, -3), 13.0], [Vector2(6, -8), 10.0], [Vector2(-4, 10), 9.0], [Vector2(22, 10), 8.0]]:
		draw_circle(position + item[0] * scale_factor, item[1] * scale_factor, color)

func _draw_mountains() -> void:
	var mountain := Color(0.35, 0.40, 0.52, 0.55)
	var snow := Color(0.92, 0.95, 1.0, 0.45)
	var peaks: Array[Array] = [[50.0, GROUND_Y, -55.0, -140.0, 60.0], [170.0, GROUND_Y, -40.0, -110.0, 80.0], [280.0, GROUND_Y, -65.0, -170.0, 65.0], [400.0, GROUND_Y, -50.0, -130.0, 90.0], [530.0, GROUND_Y, -70.0, -190.0, 75.0], [680.0, GROUND_Y, -55.0, -150.0, 85.0], [800.0, GROUND_Y, -60.0, -165.0, 70.0], [920.0, GROUND_Y, -45.0, -120.0, 80.0], [1030.0, GROUND_Y, -65.0, -180.0, 65.0], [1160.0, GROUND_Y, -50.0, -140.0, 75.0], [1270.0, GROUND_Y, -55.0, -150.0, 60.0]]
	for peak in peaks:
		var x: float = peak[0]; var y: float = peak[1]; var left: float = peak[2]; var top: float = peak[3]; var right: float = peak[4]
		draw_colored_polygon(PackedVector2Array([Vector2(x + left, y), Vector2(x, y + top), Vector2(x + right, y)]), mountain)
		draw_colored_polygon(PackedVector2Array([Vector2(x + left * 0.3, y + top * 0.25), Vector2(x, y + top), Vector2(x + right * 0.3, y + top * 0.25), Vector2(x + left * 0.15, y + top * 0.35)]), snow)
	var hill_color := Color(0.40, 0.55, 0.30, 0.65)
	for hill in [[0.0, GROUND_Y, 180.0, -45.0], [150.0, GROUND_Y, 120.0, -35.0], [320.0, GROUND_Y, 150.0, -40.0], [500.0, GROUND_Y, 140.0, -30.0], [670.0, GROUND_Y, 160.0, -50.0], [850.0, GROUND_Y, 130.0, -35.0], [1000.0, GROUND_Y, 170.0, -45.0], [1180.0, GROUND_Y, 140.0, -38.0]]:
		draw_colored_polygon(PackedVector2Array([Vector2(hill[0] - hill[2], hill[1]), Vector2(hill[0], hill[1] + hill[3]), Vector2(hill[0] + hill[2], hill[1])]), hill_color)

func _draw_hills() -> void:
	var color := Color(0.45, 0.62, 0.32, 0.40)
	for hill in [[-20.0, GROUND_Y, 200.0, -30.0], [250.0, GROUND_Y, 180.0, -25.0], [480.0, GROUND_Y, 220.0, -35.0], [750.0, GROUND_Y, 190.0, -28.0], [980.0, GROUND_Y, 210.0, -32.0], [1200.0, GROUND_Y, 180.0, -25.0]]:
		draw_colored_polygon(PackedVector2Array([Vector2(hill[0] - hill[2], hill[1]), Vector2(hill[0], hill[1] + hill[3]), Vector2(hill[0] + hill[2], hill[1])]), color)

func _draw_grass_tufts() -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = 42
	var colors := [Color(0.22, 0.45, 0.14, 0.5), Color(0.18, 0.40, 0.12, 0.45), Color(0.28, 0.50, 0.18, 0.4)]
	for i in range(80):
		var x := rng.randf() * VIEW_W; var height := 4.0 + rng.randf() * 10.0; var lean := (rng.randf() - 0.5) * 4.0; var thickness := 1.0 + rng.randf()
		draw_line(Vector2(x, GROUND_Y), Vector2(x + lean, GROUND_Y - height), colors[i % 3], thickness)
		if rng.randf() > 0.5: draw_line(Vector2(x, GROUND_Y), Vector2(x + lean * 0.7 + 1.0, GROUND_Y - height * 0.8), colors[i % 3], thickness * 0.7)

func _draw_ground_details() -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = 123
	for _i in range(12):
		var x := rng.randf() * VIEW_W; var y := GROUND_Y + 2.0 + rng.randf() * 8.0; var size := 2.0 + rng.randf() * 3.0
		var color := Color(0.35 + rng.randf() * 0.1, 0.32 + rng.randf() * 0.08, 0.28 + rng.randf() * 0.05, 0.6)
		draw_circle(Vector2(x, y), size, color); draw_circle(Vector2(x + 1.0, y - 1.0), size * 0.6, Color(color.r + 0.05, color.g + 0.05, color.b + 0.05, color.a))
	for _i in range(8):
		var x := rng.randf() * VIEW_W; var y := GROUND_Y + 1.0 + rng.randf() * 4.0
		var color := Color(0.85 + rng.randf() * 0.15, 0.70 + rng.randf() * 0.2, 0.20 + rng.randf() * 0.3, 0.7)
		draw_circle(Vector2(x, y), 2.0, color); draw_line(Vector2(x, y), Vector2(x, y + 3.0), Color(0.22, 0.45, 0.14, 0.6), 1.0)
