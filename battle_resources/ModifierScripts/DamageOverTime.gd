class_name BattlefieldNextTurnDamageModifier
extends BattlefieldAttackModifier

@export var damage: int = 0

# Returns true on skip turn
func execute(player: BattlefieldPlayerEntity, enemy: BattlefieldAIEntity,
		additional_data: Dictionary) -> bool:
	var is_players_turn: bool = additional_data["is_players_turn"]
	var apply_to_player: bool = true
	# As enemy_entity apply to self
	if apply_to_self and not is_players_turn:
		apply_to_player = false
	# As player_entity apply to enemy_entity
	elif not apply_to_self and is_players_turn:
		apply_to_player = false

	var damage_data: Dictionary = {
		"damage": damage,
		"resonate_type": additional_data["resonate_type"],
		"capture_rate": additional_data["efficiency_capture_rate"],
	}

	# This is flipped to apply DoT
	if apply_to_player:
		enemy.take_damage(damage_data)
	else:
		player.take_damage(damage_data)

	return false

