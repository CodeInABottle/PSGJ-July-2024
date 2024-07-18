class_name FlaskBar
extends TextureProgressBar

@export var color: Color

func _ready() -> void:
	tint_progress = color
	value = 100

func update_value(current: int) -> void:
	value = float(current)
