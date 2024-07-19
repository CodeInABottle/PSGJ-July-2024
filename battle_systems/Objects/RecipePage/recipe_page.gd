class_name BattlefieldRecipePage
extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var label: Label = %Label
@onready var left_texture: TextureRect = %LeftTexture
@onready var right_texture: TextureRect = %RightTexture

func set_data(recipe_name: String, left_reagent: Texture, right_reagent: Texture) -> void:
	label.text = recipe_name
	left_texture.texture = left_reagent
	right_texture.texture = right_reagent
	if right_reagent == null:
		right_texture.hide()
	else:
		right_texture.show()
	animation_player.play("Hover")

func _on_hidden() -> void:
	animation_player.stop()
