@tool
extends MarginContainer

signal pressed

@export_multiline var text: String = "":
	set(value):
		text = value
		%Label.text = value

@export var tutorial_link: Control = null
@export var confirm_buttons: Array[Button] = []

func _ready() -> void:
	get_parent().hide()

	for button: Button in confirm_buttons:
		button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	get_parent().hide()
	pressed.emit()
	if tutorial_link:
		tutorial_link.show()
