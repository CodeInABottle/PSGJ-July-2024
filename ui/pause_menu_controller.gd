extends Control

@export var save_button: Button
@export var respawn_button: Button

func _ready() -> void:
	save_button.pressed.connect(on_save_pressed)
	respawn_button.pressed.connect(on_respawn_pressed)

func on_save_pressed() -> void:
	print(SaveManager.generate_save_string())

func on_respawn_pressed() -> void:
	LevelManager.respawn()
