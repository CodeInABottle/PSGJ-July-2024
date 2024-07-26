extends HBoxContainer

@onready var bg: TextureRect = %BG
@onready var symbol: TextureRect = %Symbol
@onready var label: Label = %Label

func set_data(text: String, texture: Texture) -> void:
	label.text = text
	if texture:
		symbol.texture = texture
	else:
		bg.hide()
