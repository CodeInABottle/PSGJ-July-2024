extends Node

@onready var battlefield: BattlefieldManager = $"../.."
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine

func enter() -> void:
	battlefield.captured_shadow()
	battlefield.won_battle()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
