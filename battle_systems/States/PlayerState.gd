extends Node

@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker
@onready var control_shield: Panel = %ControlShield
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity

func enter() -> void:
	player_entity.regen_ap()
	control_shield.hide()

func exit() -> void:
	control_shield.show()
	initiative_tracker.report_requeue()

func update(_delta: float) -> void:
	pass
