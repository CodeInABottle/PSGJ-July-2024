extends Node

@onready var battlefield: BattlefieldManager = $"../.."

func enter() -> void:
	battlefield.won_battle()
	battlefield.battle_finished.emit(true)

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
