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

func update(_delta: float) -> void:
	pass

func is_dead() -> bool:
	return _health <= 0

func issue_actions() -> void:
	htn_planner.handle_planning(self, _generate_world_states())

func get_speed() -> int:
	return _data.speed

func _generate_world_states() -> Dictionary:
	return {
		"health": _health,
		"max_health": _data.max_health,
		"ap": _alchemy_points,
		"max_ap": _data.max_alchemy_points,
		"ap_regen_rate": _data.ap_regen_rate
	}
