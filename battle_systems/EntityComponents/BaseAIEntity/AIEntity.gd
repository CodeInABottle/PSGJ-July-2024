class_name BattlefieldAIEntity
extends BattlefieldEntity

signal actions_completed
signal captured

@export var enemy_status_indicator: BattlefieldEnemyStatusIndicator
@export var player_entity: BattlefieldPlayerEntity

@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var hurt_player: AnimationPlayer = %HurtPlayer
@onready var flash_player: AnimationPlayer = %FlashPlayer
@onready var animation_holder: Marker2D = %AnimationHolder

var _data: BattlefieldEnemyData
var _animation_sprite: AnimatedSprite2D
var _max_alchemy_points: int
var _alchemy_regen: int
var _alchemy_points: int
var _health: int:
	set(value):
		if value < _health:
			hurt_player.play("Hurt")
		_health = clampi(value, 0, _data.max_health)
		enemy_status_indicator.update_health(_health)
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

func take_damage(damage_data: Dictionary) -> void:
	entity_tracker.damage_taken.emit(false, damage_data)
	_health -= damage_data["damage"]
	if damage_data["resonate_type"] == _data.resonate:
		_capture_value -= ceili(damage_data["damage"] * damage_data["capture_rate"])
		flash_player.play("Flash")

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
	print(ability_data.name, " | ", ability_data.damage)

	entity_tracker.add_modification_stacks(ability_data)

	_alchemy_points -= ability_data.ap_cost
	return _alchemy_points

func _update_health(value: int) -> void:
	_health += value

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
