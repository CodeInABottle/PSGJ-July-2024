@tool
class_name HTNWarningBox
extends Panel

@onready var message_label: Label = %MessageLabel

var _accept_callback: Callable
var _decline_callback: Callable

func _ready() -> void:
	hide()

func open(message: String, accept_callable: Callable, decline_callable: Callable) -> void:
	message_label.text = message
	_accept_callback = accept_callable
	_decline_callback = decline_callable
	show()

func _reset() -> void:
	_accept_callback = Callable()
	_decline_callback = Callable()
	message_label.text = ""
	hide()

func _on_accept_button_pressed() -> void:
	if _accept_callback.is_valid():
		_accept_callback.call()
	_reset()

func _on_decline_button_pressed() -> void:
	if _decline_callback.is_valid():
		_decline_callback.call()
	_reset()
