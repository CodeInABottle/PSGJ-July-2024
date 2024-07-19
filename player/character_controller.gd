class_name Player
extends CharacterBody2D

@export var player_speed: float = 100.0
@export var player_sprite: Sprite2D
@export var player_camera: Camera2D
@export var player_phantom_camera: PhantomCamera2D

func _ready() -> void:
	PlayerStats.player = self

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		#velocity = velocity.lerp(direction * player_speed, 1.0)
		velocity = direction * player_speed
	else:
		#velocity = velocity.lerp(Vector2.ZERO, 1.0)
		velocity = Vector2.ZERO

	move_and_slide()

func _process(delta: float) -> void:
	player_sprite.set_global_position(player_sprite.get_global_position().lerp(get_global_position(), 0.1))

func teleport_to(new_position: Vector2) -> void:
	set_global_position(new_position)
	player_sprite.set_global_position(new_position)
	player_camera.set_global_position(new_position + Vector2(100.0, 100.0))
