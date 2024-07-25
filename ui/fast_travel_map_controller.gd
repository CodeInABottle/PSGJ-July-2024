class_name FastTravelMap
extends TextureRect

signal fast_travel_started(checkpoint_name: String)

@onready var map_buttons: Node = %MapButtons

var pending_button: Button = null

func _ready() -> void:
	init_map_buttons()

func init_map_buttons() -> void:
	for button: Button in map_buttons.get_children():
		button.pressed.connect(on_map_button_pressed.bind(button))

func on_map_button_pressed(button: Button) -> void:
	MenuManager.fader_controller.translucent_to_black_complete.connect(on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()
	pending_button = button
	fast_travel_started.emit(button.text)

func on_translucent_to_black_complete() -> void:
	MenuManager.fader_controller.translucent_to_black_complete.disconnect(on_translucent_to_black_complete)
	LevelManager.fast_travel(pending_button.text)
