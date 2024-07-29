class_name BattlefieldManager
extends Node

signal battle_finished(battle_data: Dictionary)

@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var tutorial_manager: BattlefieldTutorial = %TutorialManager
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var table: BattlefieldTable = %Table

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
	battle_finished.connect(_on_battle_finished)
	#setup_battle("Earth Worm")
	#setup_battle("Living Tree")
	#setup_battle("Mailbox")
	#setup_battle("Bombardier Beetle")
	#setup_battle("Armored Snail")
	#setup_battle("Niter Tiger")
	tutorial_manager._set_tutorial_state("first_combat_wisdom_complete", true)
	setup_battle("Fighting Fish")
	#setup_battle("Celestial Canine")

func setup_battle(enemy_name_encounter: String) -> void:
	table.ability_execute_requested.connect(entity_tracker.player_entity.attack)
	table.candles.pressed.connect(
		func() -> void:
			table.reagent_drop_handler.clear()
			if not PlayerStats.was_ap_used:
				PlayerStats.alchemy_points += PlayerStats.ADDITIONAL_AP_REGEN
			entity_tracker.end_turn()
	)
	entity_tracker.damage_taken.connect(
		func(is_player: bool, data: Dictionary) -> void:
			if is_player and data["damage"] > 0:
				table.shake()
	)
	enemy_name = enemy_name_encounter
	battle_state["shadow_name"] = enemy_name_encounter
	entity_tracker.initialize(enemy_name_encounter)

	entity_tracker.end_turn()
	combat_state_machine.start()
	tutorial_manager.activate()
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

func _on_battle_finished(_final_state: Dictionary) -> void:
	LevelManager.world_event_occurred.emit("battle_finished", [_final_state])

	if MenuManager.fader_controller == null: return
	if MenuManager.fader_controller.fade_out_complete == null: return

	if not MenuManager.fader_controller.fade_out_complete.is_connected(_on_fade_out_complete):
		MenuManager.fader_controller.fade_out_complete.connect(_on_fade_out_complete)
	MenuManager.fader_controller.fade_out()

func _on_fade_out_complete() -> void:
	MenuManager.fader_controller.fade_out_complete.disconnect(_on_fade_out_complete)
	LevelManager.unload_menu()
	if not battle_state["won_battle"]:
		LevelManager.respawn()
