class_name BattlefieldResonateBar
extends Node2D

const LOOK_UP_TABLE: Dictionary = {
	TypeChart.ResonateType.EARTH: 6,
	TypeChart.ResonateType.WATER: 7,
	TypeChart.ResonateType.AIR: 4,
	TypeChart.ResonateType.FIRE: 5,
	TypeChart.ResonateType.SALT: 3,
	TypeChart.ResonateType.MERCURY: 9,
	TypeChart.ResonateType.SULPHUR: 8,
	TypeChart.ResonateType.CELESTIAL: 2,
	TypeChart.ResonateType.NITER: 1,
	TypeChart.ResonateType.METAL: 0,
}

@onready var icon: Sprite2D = %Icon

func set_data(type: TypeChart.ResonateType) -> void:
	if type == TypeChart.ResonateType.NONE:
		hide()
	else:
		icon.frame = LOOK_UP_TABLE[type]
		show()
