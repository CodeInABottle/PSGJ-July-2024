class_name BattlefieldHealOverTimeMod
extends BattlefieldAttackModifier

@export var healing: int = 0

# Returns true on skip turn
func execute(player: BattlefieldPlayerEntity, enemy: BattlefieldAIEntity,
		additional_data: Dictionary) -> bool:
	var apply_to_player: bool = BattlefieldEntityTracker.do_apply_to_player(
		additional_data["is_players_turn"],
		apply_to_self
	)

	if apply_to_player:
		player.heal(healing)
	else:
		enemy.heal(healing)

	return false

