class_name Player
extends CharacterBody2D

@export var player_speed: float = 100.0

@export var player_sprite: Sprite2D
@export var player_camera: Camera2D
@export var player_phantom_camera: PhantomCamera2D

var is_moving: bool = false

var player_interact_area: Area2D

const COLLISION_OFFSET: Vector2 = Vector2(0.0, -8.0)
const PICKUP_OFFSET: float = 24.0
const VISUAL_BODY_LERP_SCALE: float = 8.0

func _ready() -> void:
	PlayerStats.player = self
	init_pickup_area.call_deferred()

func init_pickup_area() -> void:
	player_interact_area =  player_sprite.get_child(0)

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity = direction * player_speed
		is_moving = true
	else:
		velocity = Vector2.ZERO
		is_moving = false

	move_and_slide()

func _process(delta: float) -> void:
	move_sprite(delta)

func move_sprite(delta: float) -> void:
	var start_position: Vector2 = player_sprite.get_global_position()
	var desired_position: Vector2 = get_global_position() + COLLISION_OFFSET
	
	var updated_position: Vector2 = start_position.lerp(desired_position, delta * VISUAL_BODY_LERP_SCALE)
	player_sprite.set_global_position(updated_position)
	
	if is_moving:
		var move_direction: Vector2 = (desired_position - start_position).normalized()
		var interact_area_position: Vector2 = player_sprite.get_global_position() + move_direction * PICKUP_OFFSET
		player_interact_area.set_global_position(interact_area_position)
		player_interact_area.set_global_rotation(move_direction.angle())

func teleport_to(new_position: Vector2) -> void:
	set_global_position(new_position)
	player_sprite.set_global_position(new_position)
	player_camera.set_global_position(new_position + Vector2(100.0, 100.0))
