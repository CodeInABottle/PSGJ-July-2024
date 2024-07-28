class_name BattlefieldNextTurnDamageModifier
extends BattlefieldAttackModifier

@export var damage: int = 0

# Returns true on skip turn
func execute(tracker: BattlefieldEntityTracker, additional_data: Dictionary) -> bool:
	var apply_to_player: bool = BattlefieldEntityTracker.do_apply_to_player(
		additional_data["is_players_turn"],
		apply_to_self
	)
	var damage_data: Dictionary = {
		"damage": damage,
		"resonate_type": additional_data["resonate_type"],
	}

	# This is flipped to apply DoT
	if apply_to_player:
		tracker.enemy_entity.take_damage(damage_data)
	else:
		tracker.player_entity.take_damage(damage_data)

	return false

