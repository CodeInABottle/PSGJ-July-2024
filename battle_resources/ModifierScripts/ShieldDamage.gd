class_name BattlefieldShieldMod
extends BattlefieldAttackModifier

@export var shield_amount: int = 30

# Returns true on skip turn
func execute(_tracker: BattlefieldEntityTracker, additional_data: Dictionary) -> bool:
	if not additional_data.has("damage"): return false

	var damage: int = additional_data["damage"]
	additional_data["damage"] = maxi(damage - shield_amount, 0)

	return false
