class_name UnitDefinition
extends Resource

@export var id: StringName
@export var display_name: String
@export var cost: int
@export var max_hp: float
@export var damage: float
@export var attack_interval: float
@export var attack_range: float
@export var speed: float
@export_enum("melee", "bow", "magic", "flame") var weapon: String = "melee"
@export var aoe_range: float = 0.0
@export var visual_scale: float = 0.13
@export var foot_offset: float = 0.93
@export_file var model_path: String
@export_file var sprite_path: String
@export_enum("procedural", "model_viewport", "authored_frames") var presentation: String = "procedural"
@export var presentation_scene: PackedScene
