class_name BattlefieldEntity
extends Node2D

const AP_EFFECT: PackedScene = preload("res://battle_systems/UI/APEffect/ap_effect.tscn")
const BATTLE_NUMBERS: PackedScene = preload("res://battle_systems/UI/BattleNumbers/battle_numbers.tscn")

@export var entity_tracker: BattlefieldEntityTracker
@export var effect_marker: Marker2D

@onready var attack_node: Marker2D = %AttackNode
@onready var effect_timer: Timer = %EffectTimer

var _was_cost_changed: bool = false
var _costs: Dictionary = {
	"Air": 1,
	"Earth": 1,
	"Fire": 1,
	"Water": 1,
}
var _effects_queued: Array[Dictionary] = []
var actions_done: int = 0
var ap_penality: int = 0

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

func reset_action_counter() -> void:
	actions_done = 0

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

func _play_ap_effect() -> void:
	_effects_queued.push_back({
		"effect": AP_EFFECT.instantiate(),
		"data": -ap_penality
	})
	effect_timer.start()

func _spawn_damage_number(amount: int, is_damage: bool) -> void:
	var value: int = amount
	if is_damage: value *= -1
	_effects_queued.push_back({
		"effect": BATTLE_NUMBERS.instantiate(),
		"data": value
	})
	effect_timer.start()

func _on_effect_timer_timeout() -> void:
	var effect_data: Dictionary = _effects_queued.pop_front()
	effect_marker.add_child(effect_data["effect"])
	effect_data["effect"].global_position = effect_marker.global_position
	if effect_data.has("data"):
		effect_data["effect"].play(effect_data["data"])

	if _effects_queued.is_empty(): return
	effect_timer.start()
