class_name BattlefieldRecipePage
extends Control

signal pressed

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var label: Label = %Label
@onready var reagents: Array[TextureRect] = [
	%ReagentA, %ReagentB, %ReagentC, %ReagentD
]
@onready var resonance: Sprite2D = %Resonance

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
	animation_player.play("Hover")

func get_ability_name() -> String:
	return label.text

func _on_hidden() -> void:
	animation_player.stop()

func _on_button_pressed() -> void:
	if not visible: return

	pressed.emit()
	hide()
