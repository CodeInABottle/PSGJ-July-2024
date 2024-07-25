class_name BattlefieldEntity
extends Node2D

@export var entity_tracker: BattlefieldEntityTracker
@onready var attack_node: Marker2D = %AttackNode

var _was_cost_changed: bool = false
var _costs: Dictionary = {
	"Air": 1,
	"Earth": 1,
	"Fire": 1,
	"Water": 1,
}

func set_cost(reagent: TypeChart.ResonateType, cost_type: TypeChart.CostType, cost: int) -> void:
	var key: String
	match reagent:
		TypeChart.ResonateType.AIR:
			key = "Air"
		TypeChart.ResonateType.EARTH:
			key = "Earth"
		TypeChart.ResonateType.FIRE:
			key = "Fire"
		TypeChart.ResonateType.WATER:
			key = "Water"
		_:
			assert(false, "What happen here?")

	match cost_type:
		TypeChart.CostType.REDUCE:
			_costs[key] = maxi(_costs[key] - cost, 0)
		TypeChart.CostType.INCREASE:
			_costs[key] = maxi(_costs[key] + cost, 0)
		TypeChart.CostType.SET:
			_costs[key] = maxi(cost, 0)

func get_cost(reagent: TypeChart.ResonateType) -> int:
	match reagent:
		TypeChart.ResonateType.AIR:
			return _costs["Air"]
		TypeChart.ResonateType.EARTH:
			return _costs["Earth"]
		TypeChart.ResonateType.FIRE:
			return _costs["Fire"]
		TypeChart.ResonateType.WATER:
			return _costs["Water"]
		_:
			assert(false, "What happen here?")
			return 0

func reset_costs() -> void:
	if not _was_cost_changed: return
	_costs["Air"] = 1
	_costs["Earth"] = 1
	_costs["Fire"] = 1
	_costs["Water"] = 1
	_was_cost_changed = false

func regen_ap() -> void:
	pass

@warning_ignore("unused_parameter")
func heal(healing: int) -> void:
	pass

@warning_ignore("unused_parameter")
func take_damage(damage_data: Dictionary) -> void:
	pass

@warning_ignore("unused_parameter")
func attack(ability_name: String) -> void:
	pass
