extends Node

@onready var battlefield: BattlefieldManager = $"../.."

func enter() -> void:
	battlefield.lost_battle()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
