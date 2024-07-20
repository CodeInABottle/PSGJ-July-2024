class_name BattlefieldManager
extends Node

@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var table: BattlefieldTable = $Table
@onready var bell: Control = %Bell

var _finished_setup: bool = false

# TEMP -- Remove on Integration
func _ready() -> void:
	setup_battle("Tree")

func setup_battle(enemy_name_encounter: String) -> void:
	table.ability_execute_requested.connect(
		func(ability_name: String) -> void:
			entity_tracker.enemy_entity.take_damage(EnemyDatabase.get_ability_damage_data(ability_name))
			entity_tracker.add_modification_stacks(EnemyDatabase.get_ability_mods(ability_name))
	)
	bell.pressed.connect(
		func() -> void:
			table.reagent_drop_handler.clear()
			if not PlayerStats.was_ap_used:
				PlayerStats.alchemy_points += PlayerStats.ADDITIONAL_AP_REGEN
			entity_tracker.end_turn()
	)
	entity_tracker.initialize(enemy_name_encounter)

	entity_tracker.end_turn()
	combat_state_machine.start()
	_finished_setup = true

func _physics_process(delta: float) -> void:
	if not _finished_setup: return

	combat_state_machine.update(delta)
