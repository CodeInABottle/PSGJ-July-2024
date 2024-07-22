class_name ComponentCostAlteration
extends BattlefieldAttackModifier

@export var resonate_type: TypeChart.ResonateType = TypeChart.ResonateType.NONE
@export var cost_type: TypeChart.CostType = TypeChart.CostType.REDUCE
@export var amount: int = 0

func execute(player: BattlefieldPlayerEntity, enemy: BattlefieldAIEntity,
		additional_data: Dictionary) -> bool:
	assert(resonate_type != TypeChart.ResonateType.NONE, "This can't be None silly~.")

	var apply_to_player: bool = BattlefieldEntityTracker.do_apply_to_player(
		additional_data["is_players_turn"],
		apply_to_self
	)
	if apply_to_player:
		player.set_cost(resonate_type, cost_type, amount)
	else:
		enemy.set_cost(resonate_type, cost_type, amount)

	return false
