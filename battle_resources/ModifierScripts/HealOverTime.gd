class_name BattlefieldHealOverTimeMod
extends BattlefieldAttackModifier

@export var healing: int = 0

# Returns true on skip turn
func execute(tracker: BattlefieldEntityTracker, additional_data: Dictionary) -> bool:
	var apply_to_player: bool = BattlefieldEntityTracker.do_apply_to_player(
		additional_data["is_players_turn"],
		apply_to_self
	)

	if apply_to_player:
		tracker.player_entity.heal(healing)
	else:
		tracker.enemy_entity.heal(healing)

	return false

