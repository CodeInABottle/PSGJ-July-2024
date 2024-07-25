class_name BattlefieldCounterMod
extends BattlefieldAttackModifier

@export var counter_damage: int = 0

# Returns true on skip turn
func execute(player: BattlefieldPlayerEntity, enemy: BattlefieldAIEntity,
		additional_data: Dictionary) -> bool:
	var damage_data: Dictionary = {
		"damage": counter_damage,
		"resonate_type": additional_data["resonate_type"],
		"capture_rate": additional_data["efficiency_capture_rate"],
	}
	# The entity that has the attack phase takes the damage
	if additional_data["is_players_turn"]:
		player.take_damage(damage_data)
	else:
		enemy.take_damage(damage_data)

	return false
