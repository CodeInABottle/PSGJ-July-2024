extends Control

@onready var pins: Control = %Pins

func _ready() -> void:
	for pin: Control in pins.get_children():
		pin.hide_all()

