extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker

func enter() -> void:
	# End battle if died of effects/Check for turn skipping
	if entity_tracker.handle_enemy_effects():
		print("skipping enemy turn")
		return

	entity_tracker.enemy_entity.reset_action_counter()
	entity_tracker.enemy_entity.regen_ap()
	entity_tracker.enemy_entity.issue_actions()

func exit() -> void:
	entity_tracker.enemy_entity.reset_costs()

func update(_delta: float) -> void:
	pass
