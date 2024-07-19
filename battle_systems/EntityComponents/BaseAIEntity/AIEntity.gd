class_name BattlefieldAIEntity
extends BattlefieldEntity

signal actions_completed

@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var enemy_status_indicator: BattlefieldEnemyStatusIndicator = %EnemyStatusIndicator

var _data: BattlefieldEnemyData
var _alchemy_points: int
var _health: int:
	set(value):
		_health = clampi(value, 0, _data.max_health)
		enemy_status_indicator.update_health(_health)
var _capture_value: int = 100

func load_AI(data: BattlefieldEnemyData) -> void:
	_data = data
	_health = data.max_health
	htn_planner.domain_name = data.domain
	sprite_2d.texture = data.sprite
	htn_planner.finished.connect(
		func() -> void:
			actions_completed.emit()
	)
	enemy_status_indicator.set_resonate(data.resonate)
	enemy_status_indicator.set_health_data(data.max_health)

func regen_ap() -> void:
	_alchemy_points = clampi(_alchemy_points + _data.ap_regen_rate, 0, _data.max_alchemy_points)

func get_speed() -> int:
	return _data.speed

func take_damage(damage_data: Dictionary) -> void:
	_health -= damage_data["damage"]
	if damage_data["resonate_type"] == _data.resonate:
		_capture_value -= ceili(damage_data["damage"] * damage_data["capture_rate"])

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
		PlayerStats.health -= ability_data.damage

	match ability_data.effect:
		0:	# None
			pass
		1:	# Heal
			_health = clampi(_health + ability_data.healing, 0, _data.max_health)
		2, 3, 4, 5:	# Burning, Drowning, Suffication, Daze
			# Apply Effect to player
			pass

	_alchemy_points -= ability_data.get_ap_usage()
	return _alchemy_points

func _update_health(value: int) -> void:
	_health += value

func _generate_world_states() -> Dictionary:
	var data: Dictionary = {
		"rng": randi_range(0, 100),
		"health": _health,
		"max_health": _data.max_health,
		"ap": _alchemy_points,
		"max_ap": _data.max_alchemy_points,
		"ap_regen_rate": _data.ap_regen_rate,
		"ability_count": _data.abilities.size()
	}
	var idx: int = 0
	for ability: BattlefieldAbility in _data.abilities:
		data.merge(ability.get_world_states(idx), true)
		idx += 1

	return data
