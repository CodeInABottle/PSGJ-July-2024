extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker

var _current_enemy: BattlefieldAIEntity
var _entered := false

func enter() -> void:
	_current_enemy = initiative_tracker.current_entity as BattlefieldAIEntity
	_current_enemy.actions_completed.connect(_on_action_complete)
	_entered = true

func exit() -> void:
	_entered = false
	_current_enemy.actions_completed.disconnect(_on_action_complete)

	if _current_enemy.health <= 0:
		initiative_tracker.report_remove()
	else:
		initiative_tracker.report_requeue()
	_current_enemy = null

func update(delta: float) -> void:
	if not _entered: return

	_current_enemy.update(delta)

func _on_action_complete() -> void:
	combat_state_machine.switch_state("InitiativeFetch")
