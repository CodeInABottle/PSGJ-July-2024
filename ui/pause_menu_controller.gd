extends Control

@export var save_button: Button

func _ready() -> void:
	save_button.pressed.connect(on_save_pressed)

func on_save_pressed() -> void:
	print(SaveManager.generate_save_string())
