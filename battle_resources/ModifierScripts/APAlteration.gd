class_name APAlteration
extends BattlefieldAttackModifier

@export var amount: int = 0

func execute(tracker: BattlefieldEntityTracker, additional_data: Dictionary) -> bool:
	var apply_to_player: bool = BattlefieldEntityTracker.do_apply_to_player(
		additional_data["is_players_turn"],
		apply_to_self
	)

	# Flipped to be used on opponent
	if apply_to_player:
		tracker.enemy_entity.ap_penality += amount
	else:
		tracker.player_entity.ap_penality += amount

	return false
