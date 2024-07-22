extends Node

@onready var battlefield: BattlefieldManager = $"../.."
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine

func enter() -> void:
	battlefield.captured_shadow()
	combat_state_machine.switch_state("RewardState")

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
