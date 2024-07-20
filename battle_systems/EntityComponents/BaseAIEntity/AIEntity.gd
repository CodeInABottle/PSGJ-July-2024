class_name BattlefieldAIEntity
extends BattlefieldEntity

signal actions_completed
signal captured

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var hurt_player: AnimationPlayer = %HurtPlayer
@onready var flash_player: AnimationPlayer = %FlashPlayer
@onready var sprite_animator: AnimationPlayer = %SpriteAnimator

var _enemy_status_indicator: BattlefieldEnemyStatusIndicator
var _player_entity: BattlefieldPlayerEntity
var _data: BattlefieldEnemyData
var _max_alchemy_points: int
var _alchemy_regen: int
var _alchemy_points: int
var _health: int:
	set(value):
		if value < _health:
			hurt_player.play("Hurt")
		_health = clampi(value, 0, _data.max_health)
		_enemy_status_indicator.update_health(_health)
var _capture_value: int = 100:
	set(value):
		_capture_value = value
		print(_capture_value)
		if is_captured():
			captured.emit()

func load_AI(data: BattlefieldEnemyData, enemy_status_indicator: BattlefieldEnemyStatusIndicator,
		player_entity: BattlefieldPlayerEntity) -> void:
	htn_planner.finished.connect( func() -> void: actions_completed.emit() )
	_enemy_status_indicator = enemy_status_indicator
	_player_entity = player_entity
	_data = data
	_health = data.max_health
	htn_planner.domain_name = data.domain
	sprite_2d.texture = data.sprite

	var alchemy_data: Dictionary = EnemyDatabase.get_alchemy_data(_data.name)
	_max_alchemy_points = alchemy_data["ap"]
	_alchemy_regen = alchemy_data["regen"]
	_alchemy_points = _max_alchemy_points

	_enemy_status_indicator.set_resonate(data.resonate)
	_enemy_status_indicator.set_health_data(data.max_health)
	sprite_animator.play("Idle")

func regen_ap() -> void:
	_alchemy_points = clampi(_alchemy_points + _alchemy_regen, 0, _max_alchemy_points)

func take_damage(damage_data: Dictionary) -> void:
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
		_player_entity.take_damage(ability_data.damage)

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
