class_name Projectile
extends Node2D

var start: Vector2 = Vector2.ZERO
var end: Vector2 = Vector2.ZERO
var progress: float = 0.0
var speed: float = 1.0 / 0.35
var target: Troop = null
var damage: float = 9.0
var kind: String = "arrow"
var done: bool = false

var _color: Color = Color(0.74, 0.74, 0.74)
var _glow: Color = Color(0.74, 0.74, 0.74, 0.3)
var _trail: Array[Vector2] = []


func setup(p_start: Vector2, p_end: Vector2, p_target: Troop, p_damage: float, p_kind: String, p_speed: float) -> void:
	start = p_start
	end = p_end
	target = p_target
	damage = p_damage
	kind = p_kind
	speed = p_speed
	match kind:
		"magic":
			_color = Color(0.60, 0.45, 1.0)
			_glow = Color(0.50, 0.35, 0.90, 0.25)
		"bolt":
			_color = Color(0.70, 0.70, 0.75)
			_glow = Color(0.60, 0.60, 0.65, 0.15)
		_:
			_color = Color(0.65, 0.55, 0.40)
			_glow = Color(0.55, 0.45, 0.30, 0.15)


func update_progress(dt: float) -> bool:
	progress += speed * dt
	_trail.append(current_position())
	if _trail.size() > 8:
		_trail.pop_front()
	if progress >= 1.0:
		done = true
		return true
	return false


func current_position() -> Vector2:
	var p: float = clamp(progress, 0.0, 1.0)
	var pos: Vector2 = start.lerp(end, p)
	var arc_ht: float = 18.0 if kind == "bolt" else sin(p * PI) * 24.0
	pos.y -= arc_ht
	return pos


func _draw() -> void:
	var pos: Vector2 = current_position()
	var ang: float = end.angle_to_point(start) + PI

	for i in _trail.size():
		var alpha: float = float(i) / float(_trail.size()) * 0.3
		var tpos: Vector2 = _trail[i]
		var tsiz: float = 1.0 + float(i) / float(_trail.size()) * 2.0
		draw_circle(tpos, tsiz, Color(_color.r, _color.g, _color.b, alpha))

	var t: Transform2D = Transform2D()
	t.x = Vector2(cos(ang), sin(ang))
	t.y = Vector2(-sin(ang), cos(ang))
	t.origin = pos
	draw_set_transform_matrix(t)

	if kind == "bolt":
		draw_line(Vector2(-12.0, 0.0), Vector2(16.0, 0.0), Color(0.23, 0.13, 0.06), 3.5)
		draw_line(Vector2(-10.0, 0.0), Vector2(14.0, 0.0), Color(0.40, 0.30, 0.20), 2.0, true)
		var head := PackedVector2Array([Vector2(18.0, 0.0), Vector2(12.0, -5.0), Vector2(12.0, 5.0)])
		draw_colored_polygon(head, _color)
		draw_circle(Vector2(pos.x, pos.y), 3.0, _glow)
	elif kind == "magic":
		draw_circle(Vector2.ZERO, 8.0, Color(0.60, 0.45, 1.0, 0.35))
		draw_circle(Vector2.ZERO, 5.0, Color(0.65, 0.50, 1.0, 0.6))
		draw_circle(Vector2.ZERO, 3.0, _color)
		draw_circle(Vector2(-10.0, 3.0), 2.5, Color(0.70, 0.55, 1.0, 0.6))
		draw_circle(Vector2(-14.0, -1.0), 2.0, Color(0.60, 0.45, 1.0, 0.4))
		draw_circle(Vector2(-16.0, 4.0), 1.5, Color(0.70, 0.55, 1.0, 0.3))
		draw_circle(Vector2(0.0, 0.0), 8.0, Color(0.60, 0.45, 1.0, 0.15))
	else:
		draw_line(Vector2(-8.0, 0.0), Vector2(10.0, 0.0), Color(0.36, 0.23, 0.12), 2.0)
		var head := PackedVector2Array([Vector2(12.0, 0.0), Vector2(7.0, -4.0), Vector2(7.0, 4.0)])
		draw_colored_polygon(head, _color)
		var fletch := PackedVector2Array([Vector2(-8.0, 0.0), Vector2(-12.0, -4.0), Vector2(-7.0, 0.0), Vector2(-12.0, 4.0)])
		draw_colored_polygon(fletch, Color(0.78, 0.16, 0.16))
		draw_circle(Vector2.ZERO, 2.0, Color(0.50, 0.40, 0.30, 0.3))

	draw_set_transform_matrix(Transform2D())
