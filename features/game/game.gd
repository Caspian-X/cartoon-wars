class_name Game
extends Node2D

const GROUND_Y := 634.0
const BASE_MAX_HP := 180.0
const MANA_MAX := 10.0
const MANA_REGEN := 1.0 / 1.8
const AI_INTERVAL := 1.2
const CROSSBOW_DMG := 7.0
const STATE_MENU := "menu"
const STATE_LEVEL_SELECT := "level_select"
const STATE_PLAYING := "playing"
const STATE_OVER := "over"
const TROOP_TYPES: Array[UnitDefinition] = [
	preload("res://data/units/spearman.tres"), preload("res://data/units/bowman.tres"),
	preload("res://data/units/wizard.tres"), preload("res://data/units/broadsword.tres"),
	preload("res://data/units/soldier_flamethrower.tres"),
]
const LEVELS: Array[LevelDefinition] = [preload("res://data/levels/the_beginning.tres")]

var state := STATE_MENU
var player_hp := BASE_MAX_HP
var enemy_hp := BASE_MAX_HP
var player_mana := 5.0
var ai_mana := 5.0
var ai_timer := 0.0
var time_sec := 0.0
var current_level_data: LevelDefinition = LEVELS[0]
var current_enemy_types: Array[UnitDefinition] = LEVELS[0].enemy_units

@onready var _player_base: Base = $PlayerBase
@onready var _enemy_base: Base = $EnemyBase
@onready var _combat: CombatSystem = $CombatSystem
@onready var _hud: HUD = $HUD
var _ai_system := AISpawnSystem.new()

func _ready() -> void:
	_combat.setup($Troops, $Projectiles, $Particles)
	_player_base.setup("player", BASE_MAX_HP)
	_player_base.bolt_fired.connect(_on_bolt_fired)
	_enemy_base.setup("enemy", BASE_MAX_HP)
	_enemy_base.bolt_fired.connect(_on_bolt_fired)
	_hud.set_troop_data(TROOP_TYPES)
	_hud.spawn_requested.connect(try_spawn)
	_hud.aim_changed.connect(_on_aim_changed)
	_hud.start_requested.connect(start_game)
	_hud.menu_requested.connect(_show_menu)
	_hud.level_select_requested.connect(_on_level_select_requested)
	_hud.level_selected.connect(_on_level_selected)
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
	for level in LEVELS:
		if level.id == level_id:
			current_level_data = level
			current_enemy_types = level.enemy_units
			break
	start_game()

func _reset_round() -> void:
	player_hp = BASE_MAX_HP
	enemy_hp = BASE_MAX_HP
	player_mana = 5.0
	ai_mana = 5.0
	ai_timer = 0.0
	_combat.reset()
	_player_base.hp = BASE_MAX_HP
	_player_base.crossbow_angle = 0.0
	_player_base.fire_timer = 0.6
	_enemy_base.hp = BASE_MAX_HP
	_enemy_base.crossbow_angle = 0.0
	_enemy_base.fire_timer = 0.8
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
	if state != STATE_PLAYING: return
	player_mana = min(MANA_MAX, player_mana + MANA_REGEN * dt)
	ai_mana = min(MANA_MAX, ai_mana + MANA_REGEN * dt)
	_update_ai(dt)
	var damage := _combat.update(dt, time_sec)
	if damage.x > 0.0:
		player_hp = max(0.0, player_hp - damage.x)
		_player_base.take_damage(damage.x)
	if damage.y > 0.0:
		enemy_hp = max(0.0, enemy_hp - damage.y)
		_enemy_base.take_damage(damage.y)
	var target := _combat.nearest_crossbow_target("player")
	_player_base.update_crossbow(dt, target, GROUND_Y, Vector2(_player_base.position.x, _player_base.position.y - 100.0))
	_player_base.queue_redraw()
	_enemy_base.queue_redraw()
	_hud.update_hp(player_hp, enemy_hp, BASE_MAX_HP)
	_hud.update_mana(player_mana, MANA_MAX)
	_hud.update_troop_buttons(player_mana)
	if player_hp <= 0.0 or enemy_hp <= 0.0:
		state = STATE_OVER
		_hud.show_result(enemy_hp <= 0.0)

func _update_ai(dt: float) -> void:
	ai_timer += dt
	if ai_timer < AI_INTERVAL: return
	ai_timer = 0.0
	var chosen := _ai_system.choose_unit(current_enemy_types, ai_mana)
	if chosen:
		ai_mana -= chosen.cost
		_combat.spawn_troop("enemy", chosen)

func try_spawn(type_index: int) -> void:
	if state != STATE_PLAYING: return
	var definition := TROOP_TYPES[type_index]
	if player_mana < definition.cost: return
	player_mana -= definition.cost
	_combat.spawn_troop("player", definition)

func _on_bolt_fired(start_position: Vector2, angle: float, side: String) -> void:
	_combat.spawn_bolt(start_position, angle, side, CROSSBOW_DMG)

func _on_aim_changed(delta: float) -> void:
	if state == STATE_PLAYING:
		_player_base.crossbow_angle = clamp(_player_base.crossbow_angle + delta, -0.4, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if state == STATE_MENU:
		if event.is_action_pressed("ui_accept"): _on_level_select_requested()
		return
	if state == STATE_LEVEL_SELECT: return
	for i in 5:
		if event.is_action_pressed("unit_%d" % (i + 1)): try_spawn(i)
	if event.is_action_pressed("aim_up"): _on_aim_changed(-0.05)
	if event.is_action_pressed("aim_down"): _on_aim_changed(0.05)
	if event.is_action_pressed("restart_level"): start_game()
