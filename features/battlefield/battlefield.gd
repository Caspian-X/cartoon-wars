class_name Battlefield
extends Node2D

const VIEW_W := 1280.0
const VIEW_H := 720.0
const GROUND_Y := 634.0
const LANE_MIN := 123.6
const LANE_MAX := 1156.4
const LANE_LEN := LANE_MAX - LANE_MIN
const BATTLEFIELD_MODEL := preload("res://assets/models/environment/battlefield.glb")


func _ready() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(int(VIEW_W), int(VIEW_H))
	viewport.transparent_bg = false
	viewport.own_world_3d = true
	viewport.world_3d = World3D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.32, 0.58, 0.88)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.84, 0.95)
	environment.ambient_light_energy = 0.55
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35.0, -25.0, 0.0)
	light.light_color = Color(1.0, 0.92, 0.78)
	light.light_energy = 0.65
	light.shadow_enabled = true
	viewport.add_child(light)

	var model := BATTLEFIELD_MODEL.instantiate()
	viewport.add_child(model)
	var animation_player := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation_player:
		var animation_names := animation_player.get_animation_list()
		if not animation_names.is_empty():
			animation_player.play(animation_names[0])

	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 9.0
	camera.look_at_from_position(Vector3(0.0, 4.5, 20.0), Vector3(0.0, 4.5, 0.0), Vector3.UP)
	camera.current = true
	viewport.add_child(camera)

	var sprite := Sprite2D.new()
	sprite.texture = viewport.get_texture()
	sprite.position = Vector2(VIEW_W * 0.5, VIEW_H * 0.5)
	add_child(sprite)
