class_name BattlefieldAttackModifier
extends Resource

@export var turns: int = 0

# Returns true on skip turn
func execute(_player: BattlefieldPlayerEntity, _enemy: BattlefieldAIEntity) -> bool:
	return false
