class_name BattlefieldAbility
extends Resource

@export var name: String = ""

@export_category("Stats")
@export var damage: int = 10
@export_range(1.1, 3.0, 0.05) var capture_efficiency: float = 1.1

@export_category("Effect Settings")
@export var effect: TypeChart.Effect = TypeChart.Effect.NONE
@export var turns: int = 0
@export var damage_over_time: int = 0
@export var healing: int = 0

@export_category("Reagents")
@export var reagent_a: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var reagent_b: TypeChart.ResonateType = TypeChart.ResonateType.NONE

func get_resonate_type() -> TypeChart.ResonateType:
	if reagent_a == reagent_b: return reagent_a
	if reagent_a != TypeChart.ResonateType.NONE and reagent_b == TypeChart.ResonateType.NONE:
		return reagent_a
	elif reagent_a == TypeChart.ResonateType.NONE and reagent_b != TypeChart.ResonateType.NONE:
		return reagent_b

	# Combination
	var combination: Array[TypeChart.ResonateType] = [reagent_a, reagent_b]
	if combination.has(TypeChart.ResonateType.WATER):
		if combination.has(TypeChart.ResonateType.EARTH):
			return TypeChart.ResonateType.SALT
		elif combination.has(TypeChart.ResonateType.AIR):
			return TypeChart.ResonateType.MERCURY
	elif combination.has(TypeChart.ResonateType.FIRE) and combination.has(TypeChart.ResonateType.AIR):
		return TypeChart.ResonateType.SULPHUR

	# Failed
	return TypeChart.ResonateType.NONE

func get_ap_usage() -> int:
	var ap_needed: int = 0
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

	var ap_needed: int = get_ap_usage()
	assert(ap_needed > 0, "Abilities require at least one reagent.")

	return {
		"ap_required_"+str(idx): ap_needed,
		"effect_id_"+str(idx): effect,
		"over_time_value_"+str(idx): over_time_value,
	}
