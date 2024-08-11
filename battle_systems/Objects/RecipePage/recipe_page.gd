class_name BattlefieldRecipePage
extends Control

signal pressed
signal mouse_hovered
signal mouse_left

@export var wiggle_on_set: bool = true
@export var enable_clicking: bool = true

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var label: Label = %Label
@onready var reagents: Array[TextureRect] = [
	%ReagentA, %ReagentB, %ReagentC, %ReagentD
]
@onready var resonance: Sprite2D = %Resonance
@onready var button: Button = $Control/Button

func set_data(recipe_name: String, resonate_type: TypeChart.ResonateType,
		reagent_textures: Array[Texture]) -> void:
	label.text = recipe_name

	for idx: int in 4:
		if idx < reagent_textures.size():
			reagents[idx].texture = reagent_textures[idx]
			reagents[idx].show()
		else:
			reagents[idx].hide()

	resonance.frame = TypeChart.TEXTURE_LOOK_UP_TABLE[resonate_type]
	if wiggle_on_set: wiggle()

func wiggle() -> void:
	animation_player.play("Wiggle")

func stop_wiggling() -> void:
	animation_player.stop()

func get_ability_name() -> String:
	return label.text

func _on_hidden() -> void:
	animation_player.stop()

func _on_button_pressed() -> void:
	if not visible: return
	if not enable_clicking: return

	hide()
	pressed.emit()

func _on_button_mouse_entered() -> void:
	mouse_hovered.emit()
	if LevelManager.audio_anchor:
		LevelManager.audio_anchor.play_sfx("page")

func _on_button_mouse_exited() -> void:
	mouse_left.emit()
