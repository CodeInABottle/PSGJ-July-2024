class_name BattlefieldAIEntity
extends BattlefieldEntity

signal actions_completed
signal ability_finished
signal captured

@export var enemy_status_indicator: BattlefieldEnemyStatusIndicator
@export var player_entity: BattlefieldPlayerEntity
@export var enemy_position: Marker2D

@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var hurt_player: AnimationPlayer = %HurtPlayer
@onready var flash_player: AnimationPlayer = %FlashPlayer
@onready var animation_holder: Marker2D = %AnimationHolder

var _data: BattlefieldEnemyData
var _tween: Tween
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

func _ready() -> void:
	hurt_player.animation_finished.connect(
		func(_animation_name: String) -> void:
			if _data.special_frame_idx == -1: return
			animation_holder.get_child(0).reset()
	)

func load_AI(data: BattlefieldEnemyData) -> void:
	htn_planner.finished.connect( func() -> void: actions_completed.emit() )
	_data = data
	_health = data.max_health
	_capture_value = data.max_health
	htn_planner.domain_name = data.domain
	var sprite_handler: Node2D = _data.combat_animation.instantiate()
	animation_holder.add_child(sprite_handler)

	var alchemy_data: Dictionary = EnemyDatabase.get_alchemy_data(_data.name)
	_max_alchemy_points = alchemy_data["ap"]
	_alchemy_regen = alchemy_data["regen"]
	_alchemy_points = _max_alchemy_points

	enemy_status_indicator.set_resonate(data.resonate)
	enemy_status_indicator.set_health_data(data.max_health)

func regen_ap() -> void:
	_alchemy_points = clampi(_alchemy_points + _alchemy_regen, 0, _max_alchemy_points)

func heal(health: int) -> void:
	_health += health

func take_damage(damage_data: Dictionary) -> void:
	# Skip is its an ability that does no damage
	if damage_data["damage"] == 0: return
	print("enemy taken damage: ", damage_data["damage"])

	# Check for special frame data
	if _data.special_frame_idx != -1:
		animation_holder.get_child(0).set_shadow_frame(_data.special_frame_idx)

	entity_tracker.damage_taken.emit(false, damage_data)
	_health -= damage_data["damage"]

	if damage_data["resonate_type"] == _data.resonate:
		_capture_value -= ceili(damage_data["damage"] * damage_data["capture_rate"])
		flash_player.play("Flash")

func has_ap() -> bool:
	return _alchemy_points > 0

func is_dead() -> bool:
	return _health <= 0

func is_captured() -> bool:
	return _capture_value <= 0

func get_attack_position() -> Vector2:
	return _data.attack_position

func issue_actions() -> void:
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

func _internal_attack_logic(ability_data: BattlefieldAbility) -> void:
	if ability_data["damage"] > 0:
		player_entity.take_damage({ "damage": ability_data["damage"] })
	print("Enemy used ", ability_data["name"], " to do ", ability_data["damage"])

	entity_tracker.add_modification_stacks(ability_data)
	ability_finished.emit()

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
