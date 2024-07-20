extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker
@onready var control_shield: Panel = %ControlShield
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity

func enter() -> void:
	player_entity.handle_effects()
	if PlayerStats.health <= 0:
		combat_state_machine.switch_state("GameOverState")
		return

	PlayerStats.regen_alchemy_points()
	control_shield.hide()

func exit() -> void:
	control_shield.show()
	initiative_tracker.report_requeue()

func update(_delta: float) -> void:
	pass
