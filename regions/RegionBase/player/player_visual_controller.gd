extends Node2D

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var player_pickup_area: Area2D = %PlayerPickupArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var timer: Timer = %Timer

func _on_water_detector_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(4):	# Shallow Water
		timer.stop()
		animation_player.play("Wade")
	if area.get_collision_layer_value(5):	# Swimming Water
		#timer.stop()
		animation_player.stop()
		animation_player.play("Swim")

func _on_water_detector_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(4):	# Shallow Water
		timer.start()

func _on_timer_timeout() -> void:
	animation_player.play("RESET")
