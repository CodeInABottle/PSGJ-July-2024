class_name BattlefieldAbility
extends Resource

@export var damage: int = 0
@export_range(1.1, 3.0, 0.05) var capture_efficiency: float = 1.1
@export_multiline var description: String
@export var modifiers: Array[BattlefieldAttackModifier] = []

@export_category("Reagents")
@export var resonate_type: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var reagent_a: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var reagent_b: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var reagent_c: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var reagent_d: TypeChart.ResonateType = TypeChart.ResonateType.NONE

var name: String = ""
var ap_cost: int = 0

func initialize(ability_name: String) -> void:
	name = ability_name
	if reagent_a != TypeChart.ResonateType.NONE:
		ap_cost += 1
	if reagent_b != TypeChart.ResonateType.NONE:
		ap_cost += 1
	if reagent_c != TypeChart.ResonateType.NONE:
		ap_cost += 1
	if reagent_d != TypeChart.ResonateType.NONE:
		ap_cost += 1
	assert(ap_cost > 0, "Abilities require at least one reagent.")
	assert(resonate_type != TypeChart.ResonateType.NONE, "Requires a set resonance for the recipe.")

func get_components() -> Array[TypeChart.ResonateType]:
	var components: Array[TypeChart.ResonateType] = []
	if reagent_a != TypeChart.ResonateType.NONE:
		components.push_back(reagent_a)
	if reagent_b != TypeChart.ResonateType.NONE:
		components.push_back(reagent_b)
	if reagent_c != TypeChart.ResonateType.NONE:
		components.push_back(reagent_c)
	if reagent_d != TypeChart.ResonateType.NONE:
		components.push_back(reagent_d)
	return components

func get_world_states(idx: int) -> Dictionary:
	return {
		"ap_required_"+str(idx): ap_cost,
		"damage_"+str(idx): damage,
	}
