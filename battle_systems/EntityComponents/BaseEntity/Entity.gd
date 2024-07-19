class_name BattlefieldEntity
extends Node2D

var _current_effects: Dictionary = {}

func regen_ap() -> void:
	pass

func get_speed() -> int:
	return 0

func add_effect(effect_data: Dictionary) -> void:
	if effect_data.is_empty(): return

	var effect: TypeChart.Effect = effect_data["effect"]

	if effect not in _current_effects:
		_current_effects[effect] = []
	else:
		# Don't add more stacks
		if _current_effects[effect].size >= TypeChart.MAX_EFFECT_STACK: return

	_current_effects[effect].push_back({
		"turns_remaining": effect_data["turns"],
		"amount_per_turn": effect_data["amount_per_turn"]
	})

func handle_effects() -> void:
	for effect: TypeChart.Effect in _current_effects:
		var temp_array: Array[Dictionary] = []
		while not _current_effects[effect].is_empty():
			var effect_data: Dictionary = _current_effects[effect].pop_back()

			if effect == TypeChart.Effect.HEAL:
				_update_health(effect_data["amount_per_turn"])
			else:
				_update_health(-effect_data["amount_per_turn"])
			effect_data["turns_remaining"] -= 1

			if effect_data["turns_remaining"] > 0:
				temp_array.push_back(effect_data)

		while not temp_array.is_empty():
			_current_effects[effect].push_back(temp_array.pop_back())

func _update_health(_value: int) -> void:
	pass
