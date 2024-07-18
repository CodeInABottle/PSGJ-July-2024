extends Control

@export var play_button: Button
@export var save_string_edit: TextEdit

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)

func _process(delta):
	pass

func _on_play_button_pressed() -> void:
	var save_string: String = save_string_edit.get_text()
	SaveManager.generate_scene_from_string(save_string)
