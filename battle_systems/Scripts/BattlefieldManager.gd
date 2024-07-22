class_name BattlefieldManager
extends Node

signal battle_finished(battle_data: Dictionary)

@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var table: BattlefieldTable = $Table
@onready var candles: Control = %Candles

var _finished_setup: bool = false
var enemy_name: String
var battle_state: Dictionary = {
	"captured": false,
	"shadow_name": "",
	"won_battle": false
}

# TEMP -- Remove on Integration
func _ready() -> void:
	LevelManager.menu_loaded.emit(self)
	battle_finished.connect(on_battle_finished)
	setup_battle("Living Tree")
	#setup_battle("Mailbox")
	#setup_battle("Niter Tiger")

func setup_battle(enemy_name_encounter: String) -> void:
	table.ability_execute_requested.connect(
		func(ability_name: String) -> void:
			entity_tracker.enemy_entity.take_damage(EnemyDatabase.get_ability_damage_data(ability_name))
			entity_tracker.add_modification_stacks(EnemyDatabase.get_ability_data(ability_name))
	)
	candles.pressed.connect(
		func() -> void:
			table.reagent_drop_handler.clear()
			if not PlayerStats.was_ap_used:
				PlayerStats.alchemy_points += PlayerStats.ADDITIONAL_AP_REGEN
			entity_tracker.end_turn()
	)
	enemy_name = enemy_name_encounter
	battle_state["shadow_name"] = enemy_name_encounter
	entity_tracker.initialize(enemy_name_encounter)

	entity_tracker.end_turn()
	combat_state_machine.start()
	_finished_setup = true

func _physics_process(delta: float) -> void:
	if not _finished_setup: return

	combat_state_machine.update(delta)

func captured_shadow() -> void:
	battle_state["captured"] = true

func won_battle() -> void:
	if battle_state["captured"]:
		PlayerStats.unlock_shadow(enemy_name)
	battle_state["won_battle"] = true
	print("Battle finished: ", battle_state)
	battle_finished.emit(battle_state)

func lost_battle() -> void:
	battle_state["captured"] = false
	battle_state["won_battle"] = false
	print("Battle finished: ", battle_state)
	battle_finished.emit(battle_state)

func on_battle_finished(final_state: Dictionary) -> void:
	MenuManager.fader_controller.fade_out_complete.connect(on_fade_out_complete)
	MenuManager.fader_controller.fade_out()

func on_fade_out_complete() -> void:
	MenuManager.fader_controller.fade_out_complete.disconnect(on_fade_out_complete)
	LevelManager.unload_menu()
