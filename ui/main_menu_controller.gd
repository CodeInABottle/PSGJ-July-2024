extends Control

@export var play_button: Button
@export var save_string_edit: TextEdit

var fader_controller: CanvasLayer

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	fader_controller = get_node("/root/Main/FaderLayer")

func _on_play_button_pressed() -> void:
	fader_controller.fade_out_complete.connect(on_fade_out_complete)
	fader_controller.fade_out()

func on_fade_out_complete() -> void:
	fader_controller.fade_out_complete.disconnect(on_fade_out_complete)

	var save_string: String = save_string_edit.get_text()
	SaveManager.generate_scene_from_string(save_string)
