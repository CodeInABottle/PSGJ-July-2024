extends Node

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var control_shield: Panel = %ControlShield
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity
@onready var candles: Control = %Candles

func enter() -> void:
	# End battle if died of effects
	if entity_tracker.handle_player_effects(): return

	candles.light()
	PlayerStats.regen_alchemy_points()
	control_shield.hide()

func exit() -> void:
	candles.blow()
	control_shield.show()
	player_entity.reset_costs()

func update(_delta: float) -> void:
	pass
