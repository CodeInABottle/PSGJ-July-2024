extends Node

@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker

func enter() -> void:
	initiative_tracker.setup_next_turn()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
