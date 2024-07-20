class_name BattlefieldEntityTracker
extends Node

signal damage_taken(is_player: bool)

@onready var enemy_status_indicator: BattlefieldEnemyStatusIndicator = %EnemyStatusIndicator
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity
@onready var enemy_entity: BattlefieldAIEntity = %EnemyEntity

var _enemy_effects: Array[BattlefieldAttackModifier] = []
var _enemy_signal_effects: Array[BattlefieldAttackModifier] = []

var _player_effects: Array[BattlefieldAttackModifier] = []
var _player_signal_effects: Array[BattlefieldAttackModifier] = []

var is_players_turn: bool = true

func initialize(enemy_name_encounter: String) -> void:
	damage_taken.connect(_handle_damage_taken_signal)
	PlayerStats.reset_alchemy_points()
	enemy_entity.load_AI(EnemyDatabase.get_enemy_data(enemy_name_encounter))
	enemy_entity.captured.connect(func() -> void: combat_state_machine.switch_state("CaptureState"))
	enemy_entity.actions_completed.connect(end_turn)

func end_turn() -> void:
	# Check if we need to end battle
	if PlayerStats.health <= 0:
		combat_state_machine.switch_state("GameOverState")
		return
	elif enemy_entity.is_dead():
		combat_state_machine.switch_state("RewardState")
		return
	elif enemy_entity.is_captured():
		combat_state_machine.switch_state("CaptureState")
		return

	# Reduce signal effects
	if is_players_turn:
		_reduce_signal_effect_turns(_enemy_signal_effects)
	else:
		_reduce_signal_effect_turns(_player_signal_effects)

	# Flip the turn over
	is_players_turn = not is_players_turn

	# Send to next turn
	if is_players_turn:
		combat_state_machine.switch_state("PlayerState")
	else:
		combat_state_machine.switch_state("EnemyState")

func add_modification_stacks(modifications: Array[BattlefieldAttackModifier]) -> void:
	for modification: BattlefieldAttackModifier in modifications:
		var apply_to_player: bool = true
		# As enemy_entity apply to self
		if modification.apply_to_self and not is_players_turn:
			apply_to_player = false
		# As player_entity apply to enemy_entity
		elif not modification.apply_to_self and is_players_turn:
			apply_to_player = false

		if apply_to_player:
			if modification.is_attacked_triggered:
				if modification not in _player_signal_effects:
					_player_signal_effects.push_back(modification)
			else:
				if modification not in _player_effects:
					_player_effects.push_back(modification)
		else:
			if modification.is_attacked_triggered:
				if modification not in _enemy_signal_effects:
					_enemy_signal_effects.push_back(modification)
			else:
				if modification not in _enemy_effects:
					_enemy_effects.push_back(modification)

# Returns true on state switch
func handle_enemy_effects() -> bool:
	if _handle_effects(_enemy_effects):
		end_turn()
		return true
	if enemy_entity.is_dead():
		combat_state_machine.switch_state("RewardState")
		return true
	return false

# Returns true on state switch
func handle_player_effects() -> bool:
	if _handle_effects(_player_effects):
		end_turn()
		return true
	if PlayerStats.health <= 0:
		combat_state_machine.switch_state("GameOverState")
		return true
	return false

# Returns true if turn is skipped
func _handle_effects(effects: Array[BattlefieldAttackModifier]) -> bool:
	var requeue_effects: Array[BattlefieldAttackModifier] = []
	var skip_turn: bool = false
	while not effects.is_empty():
		var data: BattlefieldAttackModifier = effects.pop_back()

		# Execute effect
		skip_turn = data.execute(player_entity, enemy_entity)

		# Reduce effect's turns
		data.turns -= 1

		# Check to requeue
		if data.turns > 0:
			requeue_effects.push_back(data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

	return skip_turn

func _reduce_signal_effect_turns(effects: Array[BattlefieldAttackModifier]) -> void:
	var requeue_effects: Array[BattlefieldAttackModifier] = []
	while not effects.is_empty():
		var data: BattlefieldAttackModifier = effects.pop_back()

		# Reduce effect's turns
		data.turns -= 1

		# Check to requeue
		if data.turns > 0:
			requeue_effects.push_back(data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

func _handle_damage_taken_signal(was_player: bool) -> void:
	if was_player:
		_handle_effects(_player_signal_effects)
	else:
		_handle_effects(_enemy_signal_effects)
