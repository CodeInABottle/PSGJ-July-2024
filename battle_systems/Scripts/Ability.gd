class_name BattlefieldAbility
extends Resource

@export var name: String = ""
@export var required_reagents: Array[TypeChart.WeaknessType] = []
@export var effect: TypeChart.Effect = TypeChart.Effect.NONE
@export var damage_over_time: int = 0
@export var healing: int = 0

func get_world_states(idx: int) -> Dictionary:
	var over_time_value: int = 0
	if effect == 1:	# Healing
		over_time_value = healing
	elif effect > 1:	# Effect
		over_time_value = damage_over_time

	return {
		"ap_required_"+str(idx): required_reagents.size(),
		"effect_id_"+str(idx): effect,
		"over_time_value_"+str(idx): over_time_value,
	}
