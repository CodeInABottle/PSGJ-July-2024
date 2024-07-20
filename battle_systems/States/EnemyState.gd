extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker

func enter() -> void:
	# End battle if died of effects
	if entity_tracker.handle_enemy_effects(): return
	entity_tracker.enemy_entity.regen_ap()
	entity_tracker.enemy_entity.issue_actions()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
