extends Control

signal pressed

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func light() -> void:
	animated_sprite_2d.play("default")

func blow() -> void:
	animated_sprite_2d.play("BurntOut")

func _on_button_pressed() -> void:
	pressed.emit()
