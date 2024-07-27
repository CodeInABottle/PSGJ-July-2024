@tool
extends MarginContainer

signal pressed

@export_multiline var text: String = "":
	set(value):
		text = value
		%Label.text = value

@export var additional_buttons: Array[Button] = []

func _ready() -> void:
	for button: Button in additional_buttons:
		button.pressed.connect(func() -> void: pressed.emit())

func _on_button_pressed() -> void:
	pressed.emit()
