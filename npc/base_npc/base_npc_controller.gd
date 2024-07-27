class_name BaseNPC
extends CharacterBody2D

@export var npc_speed: float = 80.0
@export var npc_name: String

@export var wander_x_bound: float = 200.0
@export var wander_y_bound: float = 200.0

@onready var detection_area: Area2D = %DetectionArea
@onready var vision_raycast: RayCast2D = %VisionRaycast
@onready var npc_sprite: AnimatedSprite2D = %NPCSprite
@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var nav: NavigationAgent2D = %NavAgent
@onready var shiny: Shiny = %Shiny

@onready var _start_position: Vector2 = get_global_position()
@onready var _wander_point: Vector2 = get_global_position()

signal battle_finished()

var _delta: float = 0.0
var _has_wander_point: bool = false
var _can_detect_player: bool = false
var _has_been_defeated: bool = false

const BATTLE_START_DISTANCE: float = 32.0
const WANDER_STOP_DISTANCE: float = 10.0
const LERP_SCALE: float = 25.0
const MIN_X_WANDER: float = 50.0

func _ready() -> void:
	detection_area.body_entered.connect(on_body_entered_detect_area)
	detection_area.body_exited.connect(on_body_exited_detect_area)
	enable_npc.call_deferred()

func enable_npc() -> void:
	pass

func _physics_process(delta: float) -> void:
	_delta = delta
	var world_state: Dictionary = generate_world_state()
	htn_planner.handle_planning(self, world_state)
	

func look_for_player() -> bool:
	if _can_detect_player:
		var detected_body: Player = PlayerStats.player
		var relative_position: Vector2 = detected_body.get_global_position() - get_global_position()
		vision_raycast.set_target_position(relative_position)
		vision_raycast.force_raycast_update()
		if vision_raycast.is_colliding():
			var seen_collider: Object = vision_raycast.get_collider()
			if seen_collider is Player:
				return true
	
	return false

func is_close_enough_to_player() -> bool:
	var distance: float = global_position.distance_to(PlayerStats.player.get_global_position())
	if distance < BATTLE_START_DISTANCE:
		return true
	return false

func is_close_enough_to_point(world_state: Dictionary) -> void:
	if (get_global_position() - world_state["wander_point"]).length() > WANDER_STOP_DISTANCE:
		pass
	else:
		_has_wander_point = false

func pick_point(world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var chance: float = rng.randf_range(0.0,100.0)
	var has_valid_point: bool = false
	while not has_valid_point:
		var x_pos: float = rng.randf_range(_start_position.x-wander_x_bound, _start_position.x+wander_x_bound)
		var y_pos: float = rng.randf_range(_start_position.y-wander_y_bound, _start_position.y+wander_y_bound)
		_wander_point = Vector2(x_pos, y_pos)
		nav.set_target_position(_wander_point)
		if nav.is_target_reachable():
			has_valid_point = true
		world_state["wander_point"] = _wander_point
		_has_wander_point = true

func walk_to_point(world_state: Dictionary) -> void:
	npc_sprite.play("walk", 1.0)
	if not world_state["close_enough_to_point"]:
		var next_path_point: Vector2 = nav.get_next_path_position()
		var desired_direction: Vector2 = global_position.direction_to(next_path_point)
		if abs(rad_to_deg(desired_direction.angle())) < 90.0:
			npc_sprite.flip_h = true
		else:
			npc_sprite.flip_h = false
		velocity = velocity.lerp(desired_direction * npc_speed, _delta * LERP_SCALE)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func wait_at_point(_world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time: float = rng.randf_range(0.5, 5.0)
	npc_sprite.stop()
	await get_tree().create_timer(wait_time).timeout

func chase_player(_world_state: Dictionary) -> void:
	_has_wander_point = false
	nav.set_target_position(PlayerStats.player.get_global_position())
	var next_path_point: Vector2 = nav.get_next_path_position()
	var desired_direction: Vector2 = global_position.direction_to(next_path_point)
	if abs(rad_to_deg(desired_direction.angle())) < 90.0:
			npc_sprite.flip_h = true
	else:
		npc_sprite.flip_h = false
	velocity = velocity.lerp(desired_direction * npc_speed, _delta * LERP_SCALE)
	npc_sprite.play("walk", 1.0)
	
	move_and_slide()

func start_battle(_world_state: Dictionary) -> void:
	if EnemyDatabase.get_enemy_data(npc_name) != null:
		LevelManager.menu_unloaded.connect(on_battle_finished)
		LevelManager.trigger_battle(npc_name)

func generate_world_state() -> Dictionary:
	return {
		"can_see_player" : look_for_player(),
		"close_enough_to_player": is_close_enough_to_player(),
		"has_wander_point": _has_wander_point,
		"wander_point": _wander_point,
		"close_enough_to_point": false,
		"npc_position": get_global_position(),
		"has_been_captured" : has_been_captured(),
		"has_been_defeated" : _has_been_defeated,
	}

func on_body_entered_detect_area(entered_body: Node2D) -> void:
	if entered_body is Player:
		_can_detect_player = true

func on_body_exited_detect_area(exited_body: Node2D) -> void:
	if exited_body is Player:
		_can_detect_player = false

func has_been_captured() -> bool:
	var unlocked_shadows: PackedStringArray = PlayerStats.get_all_unlocked_shadows()
	if unlocked_shadows.has(npc_name):
		return true
	return false

func on_battle_finished() -> void:
	shiny.queue_free()
	_has_been_defeated = true
	LevelManager.menu_unloaded.disconnect(on_battle_finished)
	battle_finished.emit()
	MenuManager.fader_controller.fade_in()
