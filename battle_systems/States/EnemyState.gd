extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var enemy_entity: BattlefieldAIEntity = %EnemyEntity

func enter() -> void:
	# End battle if died of effects
	if entity_tracker.handle_enemy_effects():
		print("skipping enemy turn")
		return
	entity_tracker.enemy_entity.regen_ap()
	entity_tracker.enemy_entity.issue_actions()

func exit() -> void:
	enemy_entity.reset_costs()

func update(_delta: float) -> void:
	pass
