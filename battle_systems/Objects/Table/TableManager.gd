class_name BattlefieldTable
extends Node2D

signal ability_execute_requested(ability_name: String)

@export var player_entity: BattlefieldPlayerEntity
@export var control_shield: Panel

@onready var hp_flask_bar: FlaskBar = %HPFlaskBar
@onready var ap_flask_bar: FlaskBar = %APFlaskBar
@onready var reagent_drop_handler: BattlefieldReagentDropLocation = %ReagentDropHandler
@onready var recipe_page_display: RecipePageDisplay = %RecipePageDisplay
@onready var candles: Control = %Candles
@onready var table_shaker: AnimationPlayer = %TableShaker

func _exit_tree() -> void:
	PlayerStats.ap_updated.disconnect(_on_ap_updated)
	PlayerStats.health_updated.disconnect(_on_hp_updated)

func _ready() -> void:
	reagent_drop_handler.control_shield = control_shield
	reagent_drop_handler.show()
	ap_flask_bar.set_data(PlayerStats.get_max_alchemy_points(), PlayerStats.get_max_alchemy_points(), "AP")
	PlayerStats.ap_updated.connect(_on_ap_updated)
	hp_flask_bar.set_data(PlayerStats.health, PlayerStats.max_health, "Health")
	PlayerStats.health_updated.connect(_on_hp_updated)
	reagent_drop_handler.ability_execute_requested.connect(
		func(ability_name: String) -> void:
			ability_execute_requested.emit(ability_name)
	)
	reagent_drop_handler.player_entity = player_entity

func shake() -> void:
	if table_shaker.is_playing(): return

	table_shaker.play("Shake")

func _on_ap_updated() -> void:
	ap_flask_bar.update_value(PlayerStats.alchemy_points)

func _on_hp_updated() -> void:
	hp_flask_bar.update_value(PlayerStats.health)

func _on_book_button_pressed() -> void:
	recipe_page_display.open()
