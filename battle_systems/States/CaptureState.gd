extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine

func enter() -> void:
	print("Capture")
	combat_state_machine.switch_state("RewardState")

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
