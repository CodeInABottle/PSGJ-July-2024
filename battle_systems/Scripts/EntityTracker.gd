class_name BattlefieldEntityTracker
extends Node

signal damage_taken

const AI_ENTITY: PackedScene = preload("res://battle_systems/EntityComponents/BaseAIEntity/ai_entity.tscn")

@onready var enemy_status_indicator: BattlefieldEnemyStatusIndicator = %EnemyStatusIndicator
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity
@onready var entity_spawn_location: Marker2D = %EntitySpawnLocation

var _enemy_effects: Array[BattlefieldAttackModifier] = []
var _enemy_signal_conditional_effects: Array[BattlefieldAttackModifier] = []

var _player_effects: Array[BattlefieldAttackModifier] = []
var _player_signal_conditional_effects: Array[BattlefieldAttackModifier] = []

var is_players_turn: bool = true
var enemy: BattlefieldAIEntity

func initialize(enemy_name_encounter: String) -> void:
	PlayerStats.reset_alchemy_points()
	_generate_enemy(enemy_name_encounter)
	damage_taken.connect(_handle_damage_taken_signal)

func end_turn() -> void:
	# Check if we need to end battle
	if PlayerStats.health <= 0:
		combat_state_machine.switch_state("GameOverState")
		return
	elif enemy.is_dead():
		combat_state_machine.switch_state("RewardState")
		return
	elif enemy.is_captured():
		combat_state_machine.switch_state("CaptureState")
		return

	# Flip the turn over
	is_players_turn = not is_players_turn

	# Send to next turn
	if is_players_turn:
		combat_state_machine.switch_state("PlayerState")
	else:
		combat_state_machine.switch_state("EnemyState")

# Returns true on state switch
func handle_enemy_effects() -> bool:
	if _handle_effects(_enemy_effects, enemy):
		end_turn()
		return true
	if enemy.is_dead():
		combat_state_machine.switch_state("RewardState")
		return true
	return false

# Returns true on state switch
func handle_player_effects() -> bool:
	if _handle_effects(_player_effects, player_entity):
		end_turn()
		return true
	if PlayerStats.health <= 0:
		combat_state_machine.switch_state("GameOverState")
		return true
	return false

# Returns true if turn is skipped
func _handle_effects(effects: Array[BattlefieldAttackModifier], entity: BattlefieldEntity) -> bool:
	var requeue_effects: Array[BattlefieldAttackModifier] = []
	var skip_turn: bool = false
	while not effects.is_empty():
		var data: BattlefieldAttackModifier = effects.pop_back()

		# Execute effect
		skip_turn = data.execute(player_entity, enemy)

		# Reduce effect's turns
		data.turns -= 1

		# Check to requeue
		if data.turns > 0:
			requeue_effects.push_back(data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

	return skip_turn

func _generate_enemy(enemy_name_encounter: String) -> void:
	enemy = AI_ENTITY.instantiate()
	entity_spawn_location.add_child(enemy)
	enemy.load_AI(
		EnemyDatabase.get_enemy_data(enemy_name_encounter),
		enemy_status_indicator,
		player_entity
	)
	enemy.captured.connect(func() -> void: combat_state_machine.switch_state("CaptureState"))
	enemy.actions_completed.connect(end_turn)

func _handle_damage_taken_signal() -> void:
	pass
