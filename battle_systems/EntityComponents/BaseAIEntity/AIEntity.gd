class_name BattlefieldAIEntity
extends BattlefieldEntity

signal actions_completed
signal ability_finished
signal captured
signal capture_animated
signal capture_status_animated

const MAX_RESIDUE_STACKS: int = 3
const MAX_RESIDUE_TURNS: int = 2

@export var enemy_status_indicator: BattlefieldEnemyStatusIndicator
@export var player_entity: BattlefieldPlayerEntity
@export var enemy_position: Marker2D

@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var hurt_player: AnimationPlayer = %HurtPlayer
@onready var flash_player: AnimationPlayer = %FlashPlayer
@onready var animation_holder: Marker2D = %AnimationHolder

var _data: BattlefieldEnemyData
var _sprite_handler: BattlefieldEnemySpriteHandler
var _residues: Dictionary = {
	TypeChart.ResonateType.EARTH: [],
	TypeChart.ResonateType.WATER: [],
	TypeChart.ResonateType.AIR: [],
	TypeChart.ResonateType.FIRE: [],
}
var _long_term_memory: Dictionary = {
	"highest_damage": 0,
	"ap_cost": 0
}
var _tween: Tween
var _max_alchemy_points: int
var _alchemy_regen: int
var _alchemy_points: int
var _health: int:
	set(value):
		if value < _health:
			hurt_player.play("Hurt")
			enemy_status_indicator.damage_health(_health-value)
		elif value > _health:
			enemy_status_indicator.heal_health(value-_health)
		_health = clampi(value, 0, _data.max_health)
		if _health <= 0:
			entity_tracker.end_turn()

var _capture_value: int:
	set(value):
		_capture_value = value
		enemy_status_indicator.update_capture_rate(_capture_value)
		if is_captured():
			captured.emit()


var short_term_memory: Array[Dictionary] = []

func _ready() -> void:
	hurt_player.animation_finished.connect(
		func(_animation_name: String) -> void:
			if animation_holder.get_child(0).is_set()\
					and _data.special_frame_behavior == EnemyDatabase.SpecialFrameState.ON_HURT:
				animation_holder.get_child(0).reset()
	)

func load_AI(data: BattlefieldEnemyData) -> void:
	htn_planner.finished.connect(
		func() -> void:
			if animation_holder.get_child(0).is_set()\
					and _data.special_frame_behavior == EnemyDatabase.SpecialFrameState.ON_ATTACK:
				await get_tree().create_timer(0.25).timeout
				animation_holder.get_child(0).reset()
			actions_completed.emit()
	)
	_data = data
	_health = data.max_health
	_capture_value = data.max_health
	#_capture_value = 49
	htn_planner.domain_name = data.domain
	_sprite_handler = _data.combat_animation.instantiate()
	animation_holder.add_child(_sprite_handler)
	_sprite_handler.captured.connect( func() -> void: capture_animated.emit() )

	var alchemy_data: Dictionary = EnemyDatabase.get_alchemy_data(_data.name)
	_max_alchemy_points = alchemy_data["ap"]
	_alchemy_regen = alchemy_data["regen"]
	_alchemy_points = _max_alchemy_points

	enemy_status_indicator.set_resonate(data.resonate, _capture_value)
	enemy_status_indicator.set_health_data(data.max_health)

	if _data.domain == "Clever":
		_check_if_self_can_stun()
		_long_term_memory["player_can_stun"] = PlayerStats.can_stun()
		var lowest_ap_cost: int = 1000000
		for ability: BattlefieldAbility in _data.abilities:
			if ability.ap_cost < lowest_ap_cost:
				lowest_ap_cost = ability.ap_cost
		_long_term_memory["lowest_ap_cost"] = lowest_ap_cost

func regen_ap() -> void:
	_alchemy_points = clampi(_alchemy_points + _alchemy_regen - ap_penality, 0, _max_alchemy_points)
	if ap_penality > 0:
		_play_ap_effect()
	ap_penality = 0

func heal(health: int) -> void:
	print("Enemy healed: ", health)
	_health += health

func take_damage(damage_data: Dictionary) -> void:
	# Skip is its an ability that does no damage
	if damage_data["damage"] == 0: return
	print("enemy taken damage: ", damage_data["damage"])

	# Check for special frame data -- On hurt
	if _data.special_frame_behavior == EnemyDatabase.SpecialFrameState.ON_HURT:
		animation_holder.get_child(0).set_shadow_frame(_data.special_frame_idx)
	# Check for special frame data -- Last 30% HP
	elif _data.special_frame_behavior == EnemyDatabase.SpecialFrameState.LAST_30_PRECENT:
		if _health <= ceili(float(_data.max_health) * 0.3):
			animation_holder.get_child(0).set_shadow_frame(_data.special_frame_idx)

	var trigger_capture_damage: bool = damage_data["resonate_type"] == _data.resonate
	# Check for residue capture
	if not trigger_capture_damage:
		var residues_used: Array[TypeChart.ResonateType] = _check_if_can_resonate_with_residues(damage_data)
		if not residues_used.is_empty():
			trigger_capture_damage = true
			# Reduce residues
			for type: TypeChart.ResonateType in residues_used:
				_residues[type].clear()

	# Calculate Capture
	if trigger_capture_damage:
		var capture_damage: int = ceili(damage_data["damage"] * EnemyDatabase.CAPTURE_RATE_EFFICENCY)
		print("Capture Damage: ", capture_damage)
		_capture_value -= capture_damage
		flash_player.play("Flash")
	# Didnt do capture damage, leave residues
	else:
		for type: TypeChart.ResonateType in damage_data["components"]:
			# Skip if at max stacks
			if _residues[type].size() >= MAX_RESIDUE_STACKS: continue

			_residues[type].push_back(MAX_RESIDUE_TURNS)

	# Update status residues
	_update_residues()

	# Calculate Damage
	entity_tracker.damage_taken.emit(false, damage_data)
	_health -= damage_data["damage"]

func has_ap() -> bool:
	return _alchemy_points > 0

func is_dead() -> bool:
	return _health <= 0

func is_captured() -> bool:
	return _capture_value <= 0

func play_capture_animation() -> void:
	_sprite_handler.capture()

func get_attack_position() -> Vector2:
	return _data.attack_position

func issue_actions() -> void:
	if _data.domain == "Clever":
		var accumulated_damage: int = 0
		var accumulated_ap: int = 0
		for data: Dictionary in short_term_memory:
			accumulated_damage += data["damage"]
			accumulated_ap += data["ap_used"]
		if accumulated_damage > _long_term_memory["highest_damage"]:
			_long_term_memory["highest_damage"] = accumulated_damage
			_long_term_memory["ap_cost"] = accumulated_ap
		print("Remembering: ", _long_term_memory)
	short_term_memory.clear()

	htn_planner.handle_planning(self, _generate_world_states())

func activate_ability(ability_idx: int) -> void:
	if ability_idx < 0 or ability_idx > _data.abilities.size(): return


	var ability_data: BattlefieldAbility = _data.abilities[ability_idx]
	var attack_packed_scene: PackedScene = ability_data["attack"]

	_alchemy_points -= ability_data.ap_cost

	if attack_packed_scene == null:
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_callback(
			func() -> void:
				_internal_attack_logic(ability_data)
		)
	else:
		var attack_instance: Node2D = ability_data["attack"].instantiate()
		add_child(attack_instance)
		if ability_data["moving_attack"]:
			attack_instance.global_position = _data.attack_position
			if _tween:
				_tween.kill()
			_tween = create_tween()
			_tween.tween_property(
				attack_instance, "global_position",
				enemy_position.global_position,
				ability_data["attack_movement_speed"]
			)
			_tween.tween_callback(
				func() -> void:
					attack_instance.queue_free()
					_internal_attack_logic(ability_data)
			)
		else:
			attack_instance.global_position = enemy_position.global_position
			await get_tree().create_timer(ability_data["attack_life_time"]).timeout
			attack_instance.queue_free()
			_internal_attack_logic(ability_data)

func get_most_damaging_ability_within_AP_cost() -> int:
	if _alchemy_points <= 0: return -1

	var ability_idx: int = -1
	var damage: int = 0

	var idx: int = 0
	for ability: BattlefieldAbility in _data.abilities:
		var ability_damage: int = EnemyDatabase.get_ability_damage(ability.name)
		if ability_damage > damage and _alchemy_points >= ability.ap_cost:
			damage = ability_damage
			ability_idx = idx
		idx += 1

	return ability_idx

func get_cheapest_ability() -> int:
	if _alchemy_points <= 0: return -1

	var ability_idx: int = -1
	var ap_cost: int = 100000000000

	var idx: int = 0
	for ability: BattlefieldAbility in _data.abilities:
		if ability.ap_cost < ap_cost and _alchemy_points >= ability.ap_cost:
			ap_cost = ability.ap_cost
			ability_idx = idx
		idx += 1

	return ability_idx

# Uses a brute force method
func get_ability_chain() -> Array[int]:
	if _alchemy_points <= _long_term_memory["lowest_ap_cost"]: return []

	var ability_idxs: Array[int] = []

	var abilities_chosen: Array[String] = []
	abilities_chosen\
		.assign(_knap_sack(_alchemy_points, _data.abilities, _data.abilities.size()).get("ability_names", []))
	var idx: int = 0
	for ability: BattlefieldAbility in _data.abilities:
		if ability.name in abilities_chosen:
			ability_idxs.push_back(idx)
			abilities_chosen.erase(ability.name)
		idx += 1
	return ability_idxs

func reduce_residues() -> void:
	for type: TypeChart.ResonateType in _residues.keys():
		var temp_stack: Array[int] = []
		while not _residues[type].is_empty():
			var turn_count: int = _residues[type].pop_back()

			turn_count -= 1
			if turn_count > 0:
				temp_stack.push_back(turn_count)
		_residues[type].assign(temp_stack)
	_update_residues()

func _update_residues() -> void:
	for type: TypeChart.ResonateType in _residues.keys():
		var amount: int = _residues[type].size()
		var blink: bool = false
		if amount == 1 and _residues[type][0] == 1:
			blink = true
		enemy_status_indicator.update_residues(type, amount, blink)

func _check_if_can_resonate_with_residues(damage_data: Dictionary) -> Array[TypeChart.ResonateType]:
		var resonance_breakdown: Array[TypeChart.ResonateType] = TypeChart.get_resonance_breakdown(_data.resonate)
		var used_components: Array[TypeChart.ResonateType] = damage_data["components"].duplicate()

		# Reduce residues
		var temp_resudue_usage: Dictionary = _residues.duplicate(true)
		var temp_stack: Array[TypeChart.ResonateType] = []
		while not resonance_breakdown.is_empty():
			var breakdown_type: TypeChart.ResonateType = resonance_breakdown.pop_back()
			if temp_resudue_usage[breakdown_type].is_empty():
				temp_stack.push_back(breakdown_type)
				continue

			temp_resudue_usage[breakdown_type].pop_back()

		while not temp_stack.is_empty():
			var temp_type: TypeChart.ResonateType = temp_stack.pop_back()
			if temp_type in used_components:
				used_components.erase(temp_type)
				continue
			return []

		var results: Array[TypeChart.ResonateType] = []
		for type: TypeChart.ResonateType in _residues.keys():
			if _residues[type].size() != temp_resudue_usage[type].size():
				results.push_back(type)
		return results

func _knap_sack(ap: int, abilities: Array[BattlefieldAbility], ability_count: int) -> Dictionary:
	if ability_count == 0 or ap <= 0: return {}

	if abilities[ability_count-1].ap_cost > ap:
		return _knap_sack(ap, abilities, ability_count-1)
	else:
		var ability_path_a: Dictionary\
			= _knap_sack(ap - abilities[ability_count-1].ap_cost, abilities, ability_count-1)
		var ability_path_b: Dictionary = _knap_sack(ap, abilities, ability_count-1)

		if abilities[ability_count-1].damage + ability_path_a.get("damage", 0) > ability_path_b.get("damage", 0):
			return {
				"ability_names": ability_path_a.get("ability_names", []) + [abilities[ability_count-1].name],
				"damage": ability_path_a.get("damage", 0) + abilities[ability_count-1].damage
			}
		else:
			return ability_path_b

func _check_if_self_can_stun() -> void:
	var ability_idx: int = 0
	for ability: BattlefieldAbility in _data.abilities:
		for mod: BattlefieldAttackModifier in ability.modifiers:
			if mod is BattlefieldSkipTurnMod:
				_long_term_memory["can_stun"] = true
				_long_term_memory["stun_idx"] = ability_idx
				_long_term_memory["stun_ap"] = ability.ap_cost
				return
		ability_idx += 1
	_long_term_memory["can_stun"] = false

func _internal_attack_logic(ability_data: BattlefieldAbility) -> void:
	if ability_data["damage"] > 0:
		# Check for special frame data -- On Attack
		if _data.special_frame_behavior == EnemyDatabase.SpecialFrameState.ON_ATTACK:
			animation_holder.get_child(0).set_shadow_frame(_data.special_frame_idx)

		player_entity.take_damage({ "damage": ability_data["damage"] })
	print("Enemy used ", ability_data["name"], " to do ", ability_data["damage"])

	entity_tracker.add_modification_stacks(ability_data)
	ability_finished.emit()
	actions_done += 1

func _generate_world_states() -> Dictionary:
	var data: Dictionary = {
		"rng": randi_range(0, 100),
		"health": _health,
		"above_30%_health": _health > ceili(float(_data.max_health) * 0.3),
		"max_health": _data.max_health,
		"ap": _alchemy_points,
		"at_has_max_ap": _alchemy_points >= _max_alchemy_points,
		"max_ap": _max_alchemy_points,
		"ap_regen_rate": _alchemy_regen,
		"ability_count": _data.abilities.size()
	}
	if _data.domain == "Clever":
		data.merge(_long_term_memory, true)
		data.merge({
			"player_hp": PlayerStats.health,
			"player_ap": PlayerStats.alchemy_points,
			"can_player_burst": PlayerStats.alchemy_points >= _long_term_memory["ap_cost"]\
				and _long_term_memory["highest_damage"] > 0,
			"can_use_stun": _long_term_memory.has("stun_ap") and _alchemy_points >= _long_term_memory["stun_ap"]
		})

	return data

func _on_capture_animation() -> void:
	capture_status_animated.emit()
