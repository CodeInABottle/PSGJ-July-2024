@tool
class_name TreeItemButton
extends MarginContainer

@onready var label: Label = %Label

var _callable: Callable

func initialize(text: String, callback: Callable) -> void:
	label.text = text
	_callable = callback

func _on_button_pressed() -> void:
	if _callable.is_valid():
		_callable.call()
