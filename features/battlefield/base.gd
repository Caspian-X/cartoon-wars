class_name Base
extends Node2D

signal bolt_fired(start_pos: Vector2, angle: float, side: String)

const TOWER_MODEL := preload("res://assets/models/environment/tower.glb")

var side: String = "player"
var hp: float = 180.0
var max_hp: float = 180.0
var has_crossbow: bool = true
var crossbow_angle: float = 0.0
var fire_timer: float = 0.6
var _model: Node3D
var _crossbow: Node3D


func setup(p_side: String, p_max_hp: float) -> void:
	side = p_side
	max_hp = p_max_hp
	hp = p_max_hp
	has_crossbow = side == "player"
	if is_node_ready():
		_apply_side()


func _ready() -> void:
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
	environment.ambient_light_energy = 0.7
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-38.0, -30.0, 0.0)
	light.light_color = Color(1.0, 0.9, 0.76)
	light.light_energy = 0.8
	viewport.add_child(light)

	_model = TOWER_MODEL.instantiate()
	viewport.add_child(_model)
	_crossbow = _model.find_child("CrossbowRoot", true, false) as Node3D
	var animation_player := _model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation_player:
		var animation_names := animation_player.get_animation_list()
		if not animation_names.is_empty():
			animation_player.play(animation_names[0])

	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.4
	camera.look_at_from_position(Vector3(5.5, 2.4, 6.5), Vector3(0.0, 2.2, 0.0), Vector3.UP)
	camera.current = true
	viewport.add_child(camera)

	var sprite := Sprite2D.new()
	sprite.texture = viewport.get_texture()
	sprite.position = Vector2(0.0, -64.0)
	sprite.scale = Vector2(0.62, 0.62)
	add_child(sprite)
	_apply_side()


func _apply_side() -> void:
	if not _model:
		return
	_model.scale.x = 1.0 if side == "player" else -1.0
	if _crossbow:
		_crossbow.visible = has_crossbow
	if side == "enemy":
		for mesh in _model.find_children("*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).material_overlay = _enemy_overlay()


func _enemy_overlay() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.78, 0.32, 0.28, 0.38)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _process(_dt: float) -> void:
	if _crossbow:
		_crossbow.rotation.y = -crossbow_angle


func update_crossbow(dt: float, _target: Troop, _ground_y: float, pivot: Vector2) -> void:
	if not has_crossbow:
		return
	fire_timer -= dt
	if fire_timer <= 0.0:
		fire_timer = 1.4 + randf_range(-0.15, 0.15)
		bolt_fired.emit(pivot, crossbow_angle, side)
	crossbow_angle = clamp(crossbow_angle, -0.4, 0.8)


func take_damage(amount: float) -> void:
	hp = max(0.0, hp - amount)
