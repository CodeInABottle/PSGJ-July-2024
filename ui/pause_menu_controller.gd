extends Control

@export var save_button: Button

func _ready():
	save_button.pressed.connect(on_save_pressed)
	SaveManager.attempt_load()

func on_save_pressed() -> void:
	print(SaveManager.generate_save_string())
