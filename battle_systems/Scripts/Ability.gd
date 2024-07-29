class_name BattlefieldAbility
extends Resource

@export var damage: int = 0
@export_multiline var description: String
@export var modifiers: Array[BattlefieldAttackModifier] = []

@export var moving_attack: bool = false
@export var attack_movement_speed: float = 0.5
@export var attack_life_time: float = 0.5
@export var attack: PackedScene

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

func get_world_states(idx: int) -> Dictionary:
	return {
		"ap_required_"+str(idx): ap_cost,
		"damage_"+str(idx): damage,
	}

func get_components() -> Array[TypeChart.ResonateType]:
	var components: Array[TypeChart.ResonateType] = []
	if reagent_a in TypeChart.PRIMARY_REAGENTS:
		components.push_back(reagent_a)
	if reagent_b in TypeChart.PRIMARY_REAGENTS:
		components.push_back(reagent_b)
	if reagent_c in TypeChart.PRIMARY_REAGENTS:
		components.push_back(reagent_c)
	if reagent_d in TypeChart.PRIMARY_REAGENTS:
		components.push_back(reagent_d)
	return components
