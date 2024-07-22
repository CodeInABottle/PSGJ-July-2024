class_name BattlefieldSkipTurnMod
extends BattlefieldAttackModifier

func execute(_player: BattlefieldPlayerEntity, _enemy: BattlefieldAIEntity,
		_additional_data: Dictionary) -> bool:
	#var apply_to_player: bool = BattlefieldEntityTracker.do_apply_to_player(
		#additional_data["is_players_turn"],
		#apply_to_self
	#)

	return true
