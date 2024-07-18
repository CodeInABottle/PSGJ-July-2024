class_name BattlefieldTable
extends Node2D

@export var battlefield_manager: BattlefieldManager

@onready var hp_flask_bar: FlaskBar = %HPFlaskBar
@onready var ap_flask_bar: FlaskBar = %APFlaskBar

func _ready() -> void:
	ap_flask_bar.max_value = battlefield_manager.MAX_ALCHEMY_POINTS # TEMP

	battlefield_manager.AP_changed.connect(
		func() -> void:
			ap_flask_bar.value = battlefield_manager.alchemy_points
	)
