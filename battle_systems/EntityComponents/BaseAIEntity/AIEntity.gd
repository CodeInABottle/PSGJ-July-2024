class_name BattlefieldAIEntity
extends BattlefieldEntity

signal actions_completed

@onready var htn_planner: HTNPlanner = %HTNPlanner
@onready var sprite_2d: Sprite2D = $Sprite2D

var _data: BattlefieldEnemyData
var _alchemy_points: int
var _health: int

func load_AI(data: BattlefieldEnemyData) -> void:
	_data = data
	_health = data.max_health
	htn_planner.domain_name = data.domain
	sprite_2d.texture = data.sprite
	htn_planner.finished.connect(
		func() -> void:
			actions_completed.emit()
	)

func regen_ap() -> void:
	_alchemy_points = clampi(_alchemy_points + _data.ap_regen_rate, 0, _data.max_alchemy_points)

func get_speed() -> int:
	return _data.speed

func is_dead() -> bool:
	return _health <= 0

func issue_actions() -> void:
	htn_planner.handle_planning(self, _generate_world_states())

func activate_ability(ability_idx: int) -> void:
	if ability_idx < 0 or ability_idx > _data.abilities.size(): return

	var ability_data: BattlefieldAbility = _data.abilities[ability_idx]
	if ability_data.damage > 0:
		# Do damage to player
		pass

	match ability_data.effect:
		0:	# None
			pass
		1:	# Heal
			_health = clampi(_health + ability_data.healing, 0, _data.max_health)
		2, 3, 4, 5:	# Burning, Drowning, Suffication, Daze
			# Apply Effect to player
			pass

	_alchemy_points -= ability_data.get_ap_usage()

func _generate_world_states() -> Dictionary:
	var data := {
		"health": _health,
		"max_health": _data.max_health,
		"ap": _alchemy_points,
		"max_ap": _data.max_alchemy_points,
		"ap_regen_rate": _data.ap_regen_rate
	}
	var idx := 0
	for ability: BattlefieldAbility in _data.abilities:
		data.merge(ability.get_world_states(idx), true)
		idx += 1

	return data
