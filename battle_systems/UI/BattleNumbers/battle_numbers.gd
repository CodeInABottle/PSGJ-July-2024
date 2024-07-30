extends Control

const RED: Color = Color("ac3232")
const GREEN: Color = Color("99e550")

@onready var label: Label = %Label
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func play(value: int) -> void:
	label.text = str(value)
	if value < 0:
		label.add_theme_color_override("font_color", RED)
		label.add_theme_color_override("font_outline_color", RED)
	else:
		label.add_theme_color_override("font_color", GREEN)
		label.add_theme_color_override("font_outline_color", GREEN)
	animation_player.play("Fade")
