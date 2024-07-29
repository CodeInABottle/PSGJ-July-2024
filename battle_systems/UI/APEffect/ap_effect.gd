extends Control

const RED: Color = Color("ac3232")
const GREEN: Color = Color("99e550")

signal finished

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var label: Label = %Label

func play(amount: int) -> void:
	if amount == 0: return

	label.text = str(amount)
	if amount < 0:
		label.add_theme_color_override("font_color", RED)
		label.add_theme_color_override("font_outline_color", RED)
	else:
		label.add_theme_color_override("font_color", GREEN)
		label.add_theme_color_override("font_outline_color", GREEN)
	animation_player.play("Display")

func _finished() -> void:
	finished.emit()
	queue_free()
