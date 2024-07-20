class_name Player
extends CharacterBody2D

@export var player_speed: float = 65.0

@export var player_sprite: Sprite2D
@export var player_camera: Camera2D
@export var player_phantom_camera: PhantomCamera2D

var is_moving: bool = false
var in_interaction: bool = false
var input_direction: Vector2 = Vector2.ZERO

var player_interact_area: Area2D

const COLLISION_OFFSET: Vector2 = Vector2(0.0, -8.0)
const PICKUP_OFFSET: float = 24.0
const VISUAL_BODY_LERP_SCALE: float = 8.0

func _ready() -> void:
	PlayerStats.player = self
	init_pickup_area.call_deferred()

func init_pickup_area() -> void:
	player_interact_area =  player_sprite.get_child(0)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("interact"):
			if interact():
				print("interacted with interactable!")

func _physics_process(_delta: float) -> void:
	input_direction = Input.get_vector("left", "right", "forward", "backward")
	if input_direction and not in_interaction:
		velocity = input_direction * player_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _process(delta: float) -> void:
	move_sprite(delta)

func move_sprite(delta: float) -> void:
	var start_position: Vector2 = player_sprite.get_global_position()
	var desired_position: Vector2 = get_global_position() + COLLISION_OFFSET
	
	var updated_position: Vector2 = start_position.lerp(desired_position, delta * VISUAL_BODY_LERP_SCALE)
	player_sprite.set_global_position(updated_position)
	
	if input_direction:
		var interact_area_position: Vector2 = player_sprite.get_global_position() + input_direction * PICKUP_OFFSET
		player_interact_area.set_global_position(interact_area_position)
		player_interact_area.set_global_rotation(input_direction.angle())

func teleport_to(new_position: Vector2) -> void:
	set_global_position(new_position)
	player_sprite.set_global_position(new_position)
	player_camera.set_global_position(new_position + Vector2(100.0, 100.0))

func interact() -> bool:
	if player_interact_area:
		var overlapping_areas: Array[Area2D] = player_interact_area.get_overlapping_areas()
		for overlap: Area2D in overlapping_areas:
			if overlap.is_in_group("interactable"):
				overlap.on_interacted_with()
				return true
	
	return false
