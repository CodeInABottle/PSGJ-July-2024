class_name BaseNPC
extends CharacterBody2D

@export var wander_x_bound: float = 200.0
@export var wander_y_bound: float = 200.0

@export var npc_speed: float = 80.0

@onready var detection_area: Area2D = %DetectionArea
@onready var vision_raycast: RayCast2D = %VisionRaycast
@onready var npc_sprite: AnimatedSprite2D = %NPCSprite
@onready var htn_planner: HTNPlanner = %HTNPlanner

@onready var _start_position: Vector2 = get_global_position()
@onready var _wander_point: Vector2 = get_global_position()

var _delta: float = 0.0
var _wait_progress: float = 0.0
var _has_wander_point = false

const BATTLE_START_DISTANCE: float = 32.0
const WANDER_STOP_DISTANCE: float = 2.0
const LERP_SCALE: float = 10.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	_delta = delta
	var world_state: Dictionary = generate_world_state()
	htn_planner.handle_planning(self, world_state)

func look_for_player() -> bool:
	var detected_bodies: Array = detection_area.get_overlapping_bodies()
	for detected_body: Node2D in detected_bodies:
		if detected_body is Player:
			var relative_position: Vector2 = detected_body.get_global_position() - get_global_position()
			vision_raycast.set_target_position(relative_position)
			vision_raycast.force_raycast_update()
			if vision_raycast.is_colliding():
				var seen_collider = vision_raycast.get_collider()
				if seen_collider is Player:
					return true
	
	return false

func is_close_enough_to_player() -> bool:
	if (get_global_position() - PlayerStats.player.get_global_position()).length() < BATTLE_START_DISTANCE:
		return true
	return false

func is_close_enough_to_point(world_state: Dictionary) -> void:
	if (get_global_position() - world_state["wander_point"]).length() > WANDER_STOP_DISTANCE:
		pass
	else:
		_has_wander_point = false

func pick_point(world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var x_pos: float = rng.randf_range(_start_position.x-wander_x_bound, _start_position.x+wander_x_bound)
	var y_pos: float = rng.randf_range(_start_position.y-wander_y_bound, _start_position.y+wander_y_bound)
	_wander_point = Vector2(x_pos, y_pos)
	world_state["wander_point"] = _wander_point
	_has_wander_point = true

func walk_to_point(world_state: Dictionary) -> void:
	npc_sprite.play("walk", 1.0)
	if not world_state["close_enough_to_point"]:
		var desired_direction: Vector2 = (world_state["wander_point"] - get_global_position()).normalized()
		if abs(rad_to_deg(desired_direction.angle())) < 90.0:
			npc_sprite.flip_h = true
		else:
			npc_sprite.flip_h = false
		velocity = velocity.lerp(desired_direction * npc_speed, _delta * LERP_SCALE)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func wait_at_point(world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time = rng.randf_range(0.5, 5.0)
	npc_sprite.stop()
	await get_tree().create_timer(wait_time).timeout

func chase_player(world_state: Dictionary) -> void:
	var desired_direction: Vector2 = (PlayerStats.player.get_global_position() - get_global_position()).normalized()
	if abs(rad_to_deg(desired_direction.angle())) < 90.0:
			npc_sprite.flip_h = true
	else:
		npc_sprite.flip_h = false
	velocity = velocity.lerp(desired_direction * npc_speed, _delta * LERP_SCALE)
	npc_sprite.play("walk", 1.0)
	
	move_and_slide()

func start_battle(world_state: Dictionary) -> void:
	pass

func generate_world_state() -> Dictionary:
	return {
		"can_see_player" : look_for_player(),
		"close_enough_to_player": is_close_enough_to_player(),
		"has_wander_point": _has_wander_point,
		"wander_point": _wander_point,
		"close_enough_to_point": false,
		"npc_position": get_global_position(),
	}
