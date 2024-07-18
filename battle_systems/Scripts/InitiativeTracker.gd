class_name BattlefieldInitiativeTracker
extends Node

signal new_turn_set

@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine

# Player, Enemies
var _intiative_order: Array[BattlefieldEntity] = []
var _has_been_reported := true
var current_entity: BattlefieldEntity = null

func initialize_order() -> void:
	_intiative_order.sort_custom(
		func(entityA: BattlefieldEntity, entityB: BattlefieldEntity) -> bool:
			return entityA.get_speed() >= entityB.get_speed()
	)

func register_entity(entity: BattlefieldEntity) -> void:
	if entity in _intiative_order:
		push_error("Attempted to re-add ", entity, " to the initiative queue.")
		return

	_intiative_order.push_back(entity)

func setup_next_turn() -> void:
	assert(_has_been_reported, "Current entity has not been reported on!")
	_has_been_reported = false

	# Check if the player is the only thing alive
	if _intiative_order.size() == 1:
		if _intiative_order[0] is BattlefieldPlayerEntity:
			combat_state_machine.switch_state("RewardState")
		else:
			combat_state_machine.switch_state("GameOverState")
		return

	new_turn_set.emit()
	current_entity = _intiative_order.pop_front()
	print(current_entity)
	if current_entity is BattlefieldPlayerEntity:
		combat_state_machine.switch_state("PlayerState")
	else:
		combat_state_machine.switch_state("EnemyState")

func premature_remove(entity: BattlefieldEntity) -> void:
	if entity == current_entity:
		report_remove()
		return

	if entity in _intiative_order:
		_intiative_order.erase(entity)
		entity.queue_free()

func report_remove() -> void:
	current_entity.queue_free()
	_has_been_reported = true

func report_requeue() -> void:
	_intiative_order.push_back(current_entity)
	_has_been_reported = true
