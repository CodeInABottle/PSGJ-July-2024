class_name BattlefieldEntityTracker
extends Node

signal damage_taken(is_player: bool, data: Dictionary)

class ModData:
	var mod: BattlefieldAttackModifier
	var resonate: TypeChart.ResonateType
	var efficiency_capture_rate: float

	func _init(ability: BattlefieldAbility, modifier: BattlefieldAttackModifier) -> void:
		mod = modifier
		resonate = ability.resonate_type
		efficiency_capture_rate = ability.capture_efficiency

	func get_data() -> Dictionary:
		return {
			"resonate_type": resonate,
			"efficiency_capture_rate": efficiency_capture_rate
		}

@onready var enemy_status_indicator: BattlefieldEnemyStatusIndicator = %EnemyStatusIndicator
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity
@onready var enemy_entity: BattlefieldAIEntity = %EnemyEntity

var _enemy_effects: Array[ModData] = []
var _enemy_signal_effects: Array[ModData] = []

var _player_effects: Array[ModData] = []
var _player_signal_effects: Array[ModData] = []

var is_players_turn: bool = false	# False -> Player first

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

func add_modification_stacks(ability: BattlefieldAbility) -> void:
	for modification: BattlefieldAttackModifier in ability.modifiers:
		var apply_to_player: bool = true
		# As enemy_entity apply to self
		if modification.apply_to_self and not is_players_turn:
			apply_to_player = false
		# As player_entity apply to enemy_entity
		elif not modification.apply_to_self and is_players_turn:
			apply_to_player = false

		var mod_data: ModData = ModData.new(ability, modification)

		if apply_to_player:
			if modification.is_attacked_triggered:
				if mod_data not in _player_signal_effects:
					_player_signal_effects.push_back(mod_data)
			else:
				if mod_data not in _player_effects:
					_player_effects.push_back(mod_data)
		else:
			if modification.is_attacked_triggered:
				if mod_data not in _enemy_signal_effects:
					_enemy_signal_effects.push_back(mod_data)
			else:
				if mod_data not in _enemy_effects:
					_enemy_effects.push_back(mod_data)

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
func _handle_effects(effects: Array[ModData]) -> bool:
	var requeue_effects: Array[ModData] = []
	var skip_turn: bool = false
	while not effects.is_empty():
		var data: ModData = effects.pop_back()

		# Execute effect
		var execute_data: Dictionary = {
			"is_players_turn": is_players_turn
		}
		execute_data.merge(data.get_data())
		skip_turn = data.execute(player_entity, enemy_entity, execute_data)

		# Reduce effect's turns
		data.turns -= 1

		# Check to requeue
		if data.turns > 0:
			requeue_effects.push_back(data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

	return skip_turn

func _handle_signal_effects(effects: Array[ModData], data: Dictionary) -> void:
	var requeue_effects: Array[ModData] = []
	while not effects.is_empty():
		var modifier_data: ModData = effects.pop_back()

		# Execute effect
		var execute_data: Dictionary = {
			"is_players_turn": is_players_turn
		}
		execute_data.merge(data, true)
		execute_data.merge(modifier_data.get_data())
		modifier_data.execute(player_entity, enemy_entity, execute_data)

		# Reduce effect's turns
		modifier_data.turns -= 1
		print(modifier_data.turns)
		# Check to requeue
		if modifier_data.turns > 0:
			requeue_effects.push_back(modifier_data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

func _reduce_signal_effect_turns(effects: Array[ModData]) -> void:
	var requeue_effects: Array[ModData] = []
	while not effects.is_empty():
		var data: ModData = effects.pop_back()

		# Reduce effect's turns
		data.turns -= 1

		# Check to requeue
		if data.turns > 0:
			requeue_effects.push_back(data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

func _get_execute_data() -> void:
	pass

func _handle_damage_taken_signal(was_player: bool, data: Dictionary) -> void:
	if was_player:
		_handle_signal_effects(_player_signal_effects, data)
	else:
		_handle_signal_effects(_enemy_signal_effects, data)
