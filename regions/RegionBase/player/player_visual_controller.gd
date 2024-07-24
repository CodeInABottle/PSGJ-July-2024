extends Node2D

enum State { LAND, WADE, SWIM }

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var player_pickup_area: Area2D = %PlayerPickupArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var timer: Timer = %Timer

var _state: State = State.LAND

func _on_water_detector_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(4):	# Shallow Water
		if _state == State.SWIM:
			animation_player.play("SwimToWade")
		else:
			animation_player.play("Wade")
		_state = State.WADE
	if area.get_collision_layer_value(5):	# Swimming Water
		_state = State.SWIM
		animation_player.play("Swim")

func _on_water_detector_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(4):	# Shallow Water
		if animation_player.is_playing(): return
		timer.start()

func _on_timer_timeout() -> void:
	_state = State.LAND
	animation_player.play("RESET")
