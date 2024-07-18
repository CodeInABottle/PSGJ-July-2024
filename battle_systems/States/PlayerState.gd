extends Node

@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker
@onready var control_shield: Panel = %ControlShield

func enter() -> void:
	# regen AP
	control_shield.hide()
	pass

func exit() -> void:
	control_shield.show()
	initiative_tracker.report_requeue()

func update(_delta: float) -> void:
	pass
