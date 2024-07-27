extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var control_shield: Panel = %ControlShield
@onready var table: BattlefieldTable = %Table

func enter() -> void:
	# End battle if died of effects
	if entity_tracker.handle_player_effects(): return

	entity_tracker.player_entity.reset_action_counter()
	entity_tracker.player_entity.regen_ap()
	table.candles.light()
	control_shield.hide()

func exit() -> void:
	table.candles.blow()
	control_shield.show()
	entity_tracker.player_entity.reset_costs()

func update(_delta: float) -> void:
	pass
