class_name BattlefieldTable
extends Node2D

@onready var hp_flask_bar: FlaskBar = %HPFlaskBar
@onready var ap_flask_bar: FlaskBar = %APFlaskBar

func _exit_tree() -> void:
	PlayerStats.ap_updated.disconnect(_on_ap_updated)

func _ready() -> void:
	ap_flask_bar.max_value = PlayerStats.get_max_alchemy_points()
	PlayerStats.ap_updated.connect(_on_ap_updated)

func _on_ap_updated() -> void:
	ap_flask_bar.value = PlayerStats.alchemy_points
