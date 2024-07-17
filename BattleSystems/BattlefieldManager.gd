class_name BattlefieldManager
extends Node

@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity

var _finished_setup := false

func _ready() -> void:
	_setup()
	initiative_tracker.setup_initiative()
	combat_state_machine.start()
	_finished_setup = true

func _physics_process(delta: float) -> void:
	if not _finished_setup: return

	combat_state_machine.update(delta)

func _setup() -> void:
	initiative_tracker.register_entity(player_entity)
