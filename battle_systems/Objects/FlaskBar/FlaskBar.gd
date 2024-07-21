class_name FlaskBar
extends Control

@export var color: Color

@onready var flask_progress_bar: TextureProgressBar = %FlaskProgressBar
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var label: Label = %Label

func _ready() -> void:
	label.hide()
	flask_progress_bar.tint_progress = color
	label.add_theme_color_override("font_color", color)

func set_data(value: int, max_value: int) -> void:
	flask_progress_bar.max_value = max_value
	flask_progress_bar.value = value
	label.text = str(value) + "/" + str(flask_progress_bar.max_value)

func update_value(current: int) -> void:
	flask_progress_bar.value = current
	label.text = str(current) + "/" + str(flask_progress_bar.max_value)

func _on_area_2d_mouse_entered() -> void:
	animation_player.play("Sway")

func _on_area_2d_mouse_exited() -> void:
	animation_player.stop()
	label.hide()
