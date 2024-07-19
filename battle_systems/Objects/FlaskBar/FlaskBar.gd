class_name FlaskBar
extends TextureProgressBar

@export var color: Color

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	label.hide()
	tint_progress = color
	value = 100
	label.add_theme_color_override("font_color", color)

func update_value(current: int) -> void:
	value = float(current)
	label.text = str(value) + "/" + str(max_value)

func _on_area_2d_mouse_entered() -> void:
	animation_player.play("Sway")

func _on_area_2d_mouse_exited() -> void:
	animation_player.stop()
	label.hide()
