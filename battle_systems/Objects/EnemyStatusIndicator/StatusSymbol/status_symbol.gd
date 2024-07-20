class_name StatusSymbol
extends Control

@onready var icon: TextureRect = $Icon
@onready var amount: Label = $Amount

var _type: TypeChart.Effect = TypeChart.Effect.NONE

func set_data(effect: TypeChart.Effect, sprite: Texture, stacks: int) -> void:
	icon.texture = sprite
	amount.text = str(stacks) + "x"
	_type = effect
	show()

func get_type() -> TypeChart.Effect:
	return _type

func _on_hidden() -> void:
	icon.texture = null
	amount.text = "0x"
	_type = TypeChart.Effect.NONE
