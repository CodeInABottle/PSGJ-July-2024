class_name BattlefieldAbility
extends Resource

@export var name: String = ""

@export_category("Stats")
@export var damage: int = 10
@export_range(1.1, 3.0, 0.1) var capture_efficiency: float = 1.1

@export_category("Effect Settings")
@export var effect: TypeChart.Effect = TypeChart.Effect.NONE
@export var damage_over_time: int = 0
@export var healing: int = 0

@export_category("Reagents")
@export var reagent_a: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var reagent_b: TypeChart.ResonateType = TypeChart.ResonateType.NONE

func get_ap_usage() -> int:
	var ap_needed := 0
	if reagent_a != TypeChart.ResonateType.NONE:
		ap_needed += 1
	if reagent_b != TypeChart.ResonateType.NONE:
		ap_needed += 1
	return ap_needed

func get_world_states(idx: int) -> Dictionary:
	var over_time_value: int = 0
	if effect == 1:	# Healing
		over_time_value = healing
	elif effect > 1:	# Effect
		over_time_value = damage_over_time

	var ap_needed := get_ap_usage()
	assert(ap_needed > 0, "Abilities require at least one reagent.")

	return {
		"ap_required_"+str(idx): ap_needed,
		"effect_id_"+str(idx): effect,
		"over_time_value_"+str(idx): over_time_value,
	}
