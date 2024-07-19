class_name BattlefieldTable
extends Node2D

signal ability_execute_requested(ability_name: String)

@onready var hp_flask_bar: FlaskBar = %HPFlaskBar
@onready var ap_flask_bar: FlaskBar = %APFlaskBar
@onready var reagent_drop_handler: BattlefieldReagentDropLocation = $Reagents/ReagentDropHandler

func _exit_tree() -> void:
	PlayerStats.ap_updated.disconnect(_on_ap_updated)
	PlayerStats.health_updated.disconnect(_on_hp_updated)

func _ready() -> void:
	ap_flask_bar.max_value = PlayerStats.get_max_alchemy_points()
	PlayerStats.ap_updated.connect(_on_ap_updated)
	hp_flask_bar.max_value = PlayerStats.max_health
	PlayerStats.health_updated.connect(_on_hp_updated)
	reagent_drop_handler.ability_execute_requested.connect(
		func(ability_name: String) -> void:
			ability_execute_requested.emit(ability_name)
	)

func _on_ap_updated() -> void:
	ap_flask_bar.value = PlayerStats.alchemy_points

func _on_hp_updated() -> void:
	hp_flask_bar.value = PlayerStats.health
