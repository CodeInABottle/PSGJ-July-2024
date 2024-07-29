class_name BattlefieldResonateBar
extends Node2D

@onready var icon: Sprite2D = %Icon

func set_data(type: TypeChart.ResonateType) -> void:
	if type == TypeChart.ResonateType.NONE:
		hide()
	else:
		icon.frame = TypeChart.TEXTURE_LOOK_UP_TABLE[type]
		show()
