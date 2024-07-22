extends Control

@export var save_button: Button
@export var respawn_button: Button

func _ready() -> void:
	MenuManager.pause_menu = self
	save_button.pressed.connect(on_save_pressed)
	respawn_button.pressed.connect(on_respawn_pressed)

func on_save_pressed() -> void:
	print(SaveManager.generate_save_string())

func on_respawn_pressed() -> void:
	MenuManager.fader_controller.translucent_to_black_complete.connect(on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()

func on_translucent_to_black_complete() -> void:
	MenuManager.toggle_pause_no_fade()
	MenuManager.fader_controller.translucent_to_black_complete.disconnect(on_translucent_to_black_complete)
	LevelManager.respawn()
