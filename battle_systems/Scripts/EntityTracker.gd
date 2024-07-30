class_name BattlefieldEntityTracker
extends Node

const MAX_MOD_COUNT: int = 3

signal damage_taken(is_player: bool, data: Dictionary)

class ModData:
	var mod: BattlefieldAttackModifier
	var created_by_player: bool
	var turns: int = 0
	var resonate: TypeChart.ResonateType
	var efficiency_capture_rate: float
	var ability_name: String

	func _init(ability: BattlefieldAbility, modifier: BattlefieldAttackModifier, whois: bool) -> void:
		mod = modifier
		turns = modifier.turns
		created_by_player = whois
		if ability:
			resonate = ability["resonate_type"]
			efficiency_capture_rate = EnemyDatabase.CAPTURE_RATE_EFFICENCY
			ability_name = ability.name

	func get_data() -> Dictionary:
		var components: Array[TypeChart.ResonateType] = []
		if not ability_name.is_empty():
			components.assign(EnemyDatabase.get_ability_recipe(ability_name))
		return {
			"resonate_type": resonate,
			"efficiency_capture_rate": efficiency_capture_rate,
			"components": components,
			"created_by_player": created_by_player
		}

@onready var enemy_status_indicator: BattlefieldEnemyStatusIndicator = %EnemyStatusIndicator
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity
@onready var enemy_entity: BattlefieldAIEntity = %EnemyEntity
@onready var attack_prompt: AttackPrompt = %AttackPrompt

var _enemy_effects: Array[ModData] = []
var _enemy_signal_effects: Array[ModData] = []

var _player_effects: Array[ModData] = []
var _player_signal_effects: Array[ModData] = []

var battle_over: bool = false
var is_players_turn: bool = false	# False -> Player first

static func do_apply_to_player(is_current_player: bool, apply_to_self: bool) -> bool:
	# As enemy_entity apply to self
	if apply_to_self and not is_current_player:
		return false
	# As player_entity apply to enemy_entity
	elif not apply_to_self and is_current_player:
		return false
	return true

func initialize(enemy_name_encounter: String) -> void:
	damage_taken.connect(_handle_damage_taken_signal)
	PlayerStats.reset_alchemy_points()
	enemy_entity.load_AI(EnemyDatabase.get_enemy_data(enemy_name_encounter))
	enemy_entity.captured.connect(func() -> void: combat_state_machine.switch_state("CaptureState"))
	enemy_entity.actions_completed.connect(end_turn)

func end_turn() -> void:
	if battle_over: return

	# Check if we need to end battle
	if PlayerStats.health <= 0:
		battle_over = true
		combat_state_machine.switch_state("GameOverState")
		return
	elif enemy_entity.is_captured():
		battle_over = true
		combat_state_machine.switch_state("CaptureState")
		return
	elif enemy_entity.is_dead():
		battle_over = true
		combat_state_machine.switch_state("RewardState")
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
	var skip_turn: bool = false
	for modification: BattlefieldAttackModifier in ability["modifiers"]:
		var apply_to_player: bool\
			= BattlefieldEntityTracker.do_apply_to_player(is_players_turn, modification["apply_to_self"])
		var mod_data: ModData = ModData.new(ability, modification, is_players_turn)

		# Check to see if the modification is immediate
		if modification["immediate"]:
			skip_turn = _execute({}, mod_data)
			continue

		if apply_to_player:
			if modification["is_attacked_triggered"]:
				if _at_max_mod_count(modification, _player_signal_effects): continue
				_player_signal_effects.push_back(mod_data)
			else:
				if _at_max_mod_count(modification, _player_effects): continue
				_player_effects.push_back(mod_data)
		else:
			if modification["is_attacked_triggered"]:
				if _at_max_mod_count(modification, _enemy_signal_effects): continue
				_enemy_signal_effects.push_back(mod_data)
			else:
				if _at_max_mod_count(modification, _enemy_effects): continue
				_enemy_effects.push_back(mod_data)
	if skip_turn:
		combat_state_machine.switch_state("SkippingState")

func add_modification(resonate: TypeChart.ResonateType, efficiency_capture_rate: float,
		modification: BattlefieldAttackModifier, is_player: bool) -> void:
	var apply_to_player: bool\
		= BattlefieldEntityTracker.do_apply_to_player(is_players_turn, modification["apply_to_self"])
	var mod_data: ModData = ModData.new(null, modification, is_player)
	mod_data.resonate = resonate
	mod_data.efficiency_capture_rate = efficiency_capture_rate

	# Check to see if the modification is immediate
	if modification["immediate"]:
		if _execute({}, mod_data): combat_state_machine.switch_state("SkippingState")
		return

	if apply_to_player:
		if modification["is_attacked_triggered"]:
			if _at_max_mod_count(modification, _player_signal_effects): return
			_player_signal_effects.push_back(mod_data)
		else:
			if _at_max_mod_count(modification, _player_effects): return
			_player_effects.push_back(mod_data)
	else:
		if modification["is_attacked_triggered"]:
			if _at_max_mod_count(modification, _enemy_signal_effects): return
			_enemy_signal_effects.push_back(mod_data)
		else:
			if _at_max_mod_count(modification, _enemy_effects): return
			_enemy_effects.push_back(mod_data)

# Returns true on state switch
func handle_enemy_effects() -> bool:
	if _handle_effects(_enemy_effects):
		combat_state_machine.switch_state("SkippingState")
		return true
	if enemy_entity.is_dead():
		combat_state_machine.switch_state("RewardState")
		return true
	return false

# Returns true on state switch
func handle_player_effects() -> bool:
	if _handle_effects(_player_effects):
		combat_state_machine.switch_state("SkippingState")
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
		skip_turn = _execute({}, data)

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
		_execute(data, modifier_data)

		# Reduce effect's turns
		modifier_data.turns -= 1
		# Check to requeue
		if modifier_data.turns > 0:
			requeue_effects.push_back(modifier_data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

func _reduce_signal_effect_turns(effects: Array[ModData]) -> void:
	var requeue_effects: Array[ModData] = []
	while not effects.is_empty():
		var data: ModData = effects.pop_back()

		# Mod created by the player
		if not is_players_turn and data.created_by_player:
			requeue_effects.push_back(data)
			continue
		# Mod created by enemy
		elif is_players_turn and not data.created_by_player:
			requeue_effects.push_back(data)
			continue

		# Reduce effect's turns
		data.turns -= 1

		# Check to requeue
		if data.turns > 0:
			requeue_effects.push_back(data)

	while not requeue_effects.is_empty():
		effects.push_back(requeue_effects.pop_back())

# Returns true on skipped turn
func _execute(additional_data: Dictionary, modifier_data: ModData) -> bool:
	var execute_data: Dictionary = {
		"is_players_turn": is_players_turn,
	}
	execute_data.merge(additional_data, true)
	execute_data.merge(modifier_data.get_data(), true)
	var skip_turn: bool = modifier_data.mod.execute(self, execute_data)
	additional_data.merge(execute_data, true)
	return skip_turn

func _handle_damage_taken_signal(was_player: bool, data: Dictionary) -> void:
	if was_player:
		_handle_signal_effects(_player_signal_effects, data)
	else:
		_handle_signal_effects(_enemy_signal_effects, data)

func _at_max_mod_count(mod: BattlefieldAttackModifier, data: Array[ModData]) -> bool:
	var count: int = 0
	for dat: ModData in data:
		if dat.mod == mod:
			count += 1
		if count >= MAX_MOD_COUNT:
			return true
	return false
