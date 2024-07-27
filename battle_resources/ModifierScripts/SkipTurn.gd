class_name BattlefieldSkipTurnMod
extends BattlefieldAttackModifier

@export_range(0, 100, 1) var chance: int = 100

func execute(_tracker: BattlefieldEntityTracker, _additional_data: Dictionary) -> bool:
	if chance == 100: return true
	if chance == 0: return false

	return randi_range(0, 100) <= chance
