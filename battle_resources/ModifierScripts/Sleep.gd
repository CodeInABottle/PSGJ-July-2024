class_name BattlefieldSleepMod
extends BattlefieldAttackModifier

@export var mod: BattlefieldAttackModifier

func execute(tracker: BattlefieldEntityTracker, additional_data: Dictionary) -> bool:
	var is_player_turn: bool = additional_data["is_players_turn"]

	if is_player_turn and tracker.player_entity.actions_done == 0:
		tracker.add_modification(additional_data["resonate_type"], additional_data["efficiency_capture_rate"], mod, true)
		return true
	elif not is_player_turn and tracker.enemy_entity.actions_done == 0:
		tracker.add_modification(additional_data["resonate_type"], additional_data["efficiency_capture_rate"], mod, false)
		return true

	return false
