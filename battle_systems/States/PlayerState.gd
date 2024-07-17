extends Node

@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker

func enter() -> void:
	# regen AP
	pass

func exit() -> void:
	initiative_tracker.report_requeue()

func update(_delta: float) -> void:
	pass
