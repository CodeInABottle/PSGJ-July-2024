extends Control

signal finished

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func play() -> void:
	animation_player.play("Display")

func _finished() -> void:
	finished.emit()
