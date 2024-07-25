class_name BattlefieldAIEntity
extends BattlefieldEntity

const MAX_RESIDUE_TURNS: int = 2
const MAX_RESIDUE_STACKS: int = 3

signal actions_completed
signal captured

@export var enemy_status_indicator: BattlefieldEnemyStatusIndicator
@export var player_entity: BattlefieldPlayerEntity

@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var hurt_player: AnimationPlayer = %HurtPlayer
@onready var flash_player: AnimationPlayer = %FlashPlayer
@onready var animation_holder: Marker2D = %AnimationHolder

# { (ResonateType) : [(turns_remaining (int) )...] }
var _residues: Dictionary = {
	TypeChart.ResonateType.EARTH: [0],
	TypeChart.ResonateType.WATER: [0],
	TypeChart.ResonateType.AIR: [0],
	TypeChart.ResonateType.FIRE: [0],
}
var _data: BattlefieldEnemyData
var _animation_sprite: AnimatedSprite2D
var _max_alchemy_points: int
var _alchemy_regen: int
var _alchemy_points: int
var _health: int:
	set(value):
		if value < _health:
			hurt_player.play("Hurt")
			enemy_status_indicator.update_health(_health-value)
		_health = clampi(value, 0, _data.max_health)
		if _health <= 0:
			entity_tracker.end_turn()

var _capture_value: int:
	set(value):
		_capture_value = value
		if is_captured():
			captured.emit()

func load_AI(data: BattlefieldEnemyData) -> void:
	htn_planner.finished.connect( func() -> void: actions_completed.emit() )
	_data = data
	_health = data.max_health
	_capture_value = data.max_health
	htn_planner.domain_name = data.domain
	_animation_sprite = _data.combat_animation.instantiate()
	animation_holder.add_child(_animation_sprite)

	var alchemy_data: Dictionary = EnemyDatabase.get_alchemy_data(_data.name)
	_max_alchemy_points = alchemy_data["ap"]
	_alchemy_regen = alchemy_data["regen"]
	_alchemy_points = _max_alchemy_points

	enemy_status_indicator.set_resonate(data.resonate)
	enemy_status_indicator.set_health_data(data.max_health)
	_animation_sprite.play("Idle")

func regen_ap() -> void:
	_alchemy_points = clampi(_alchemy_points + _alchemy_regen, 0, _max_alchemy_points)

func heal(health: int) -> void:
	_health += health

func take_damage(damage_data: Dictionary) -> void:
	# Spend the residue slots
	var usage: Array[TypeChart.ResonateType] = []
	usage.assign(damage_data.get("usage", []))
	if not usage.is_empty():
		print("Before: ", _residues)
		for type: TypeChart.ResonateType in usage:
			_removed_lowest_turn_residue(type)
		print("After: ", _residues)
		_update_residue_indicators()

	# Skip is its an ability that does no damage
	if damage_data["damage"] == 0: return
	print("enemy taken damage: ", damage_data["damage"])

	entity_tracker.damage_taken.emit(false, damage_data)
	_health -= damage_data["damage"]

	var components: Array[TypeChart.ResonateType] = damage_data["components"]
	for component: TypeChart.ResonateType in components:
		if component not in _residues: continue
		if _residues[component].size() >= MAX_RESIDUE_STACKS:
			for turn_entry_idx: int in _residues[component].size():
				if _residues[component][turn_entry_idx] < MAX_RESIDUE_TURNS:
					_residues[component][turn_entry_idx] = 2
					continue

		_residues[component].push_back(MAX_RESIDUE_TURNS)

	if _activate_resonance():
		_capture_value -= ceili(damage_data["damage"] * damage_data["capture_rate"])
		flash_player.play("Flash")

	_update_residue_indicators()

func has_ap() -> bool:
	return _alchemy_points > 0

func is_dead() -> bool:
	return _health <= 0

func is_captured() -> bool:
	return _capture_value <= 0

func issue_actions() -> void:
	htn_planner.handle_planning(self, _generate_world_states())

func activate_ability(ability_idx: int) -> int:
	if ability_idx < 0 or ability_idx > _data.abilities.size(): return 0

	var ability_data: BattlefieldAbility = _data.abilities[ability_idx]
	if ability_data.damage > 0:
		player_entity.take_damage({
			"damage": ability_data.damage
		})
	print("Enemy used ", ability_data.name, " to do ", ability_data.damage)

	entity_tracker.add_modification_stacks(ability_data)

	_alchemy_points -= ability_data.ap_cost
	return _alchemy_points

func reduce_residues() -> void:
	for type: TypeChart.ResonateType in _residues.keys():
		if _residues[type].is_empty(): continue

		var turns: Array = []
		while not _residues[type].is_empty():
			var turns_remaining: int = _residues[type].pop_back()

			turns_remaining -= 1

			if turns_remaining > 0:
				turns.push_back(turns_remaining)

		while not turns.is_empty():
			_residues[type].push_back(turns.pop_back())
	_update_residue_indicators()

func get_residues() -> Array[TypeChart.ResonateType]:
	var components: Array[TypeChart.ResonateType] = []

	for type: TypeChart.ResonateType in _residues.keys():
		for __: int in _residues[type].size():
			components.push_back(type)

	return components

func _removed_lowest_turn_residue(residue: TypeChart.ResonateType) -> void:
	var stack: Array[TypeChart.ResonateType] = []
	var smallest: int = MAX_RESIDUE_TURNS + 1
	var temp: int = 0
	while not _residues[residue].is_empty():
		var turn: int = _residues[residue].pop_back()
		if turn < smallest:
			if temp > 0:
				stack.push_back(temp)
			temp = turn
		else:
			stack.push_back(turn)
	while not stack.is_empty():
		_residues[residue].push_back(stack.pop_back())

func _activate_resonance() -> bool:
	var breakdown: Array[TypeChart.ResonateType] = TypeChart.get_resonance_breakdown(_data.resonate)
	if breakdown.is_empty(): return false

	var resonance_break: bool = true
	var residue_copy: Dictionary = _residues.duplicate(true)
	for component: TypeChart.ResonateType in breakdown:
		if residue_copy[component].size() <= 0:
			resonance_break = false
			break
		residue_copy[component].pop_back()

	if resonance_break:
		for component: TypeChart.ResonateType in breakdown:
			_residues[component].clear()

	return resonance_break

func _update_residue_indicators() -> void:
	for component: TypeChart.ResonateType in _residues:
		var amount: int = _residues[component].size()
		var blink: bool = false
		if amount == 1:
			blink = _residues[component][0] <= 1
		enemy_status_indicator.set_residue(component, amount, blink)

func _generate_world_states() -> Dictionary:
	var data: Dictionary = {
		"rng": randi_range(0, 100),
		"health": _health,
		"max_health": _data.max_health,
		"ap": _alchemy_points,
		"max_ap": _max_alchemy_points,
		"ap_regen_rate": _alchemy_regen,
		"ability_count": _data.abilities.size()
	}
	var idx: int = 0
	for ability: BattlefieldAbility in _data.abilities:
		data.merge(ability.get_world_states(idx), true)
		idx += 1

	return data
