class_name BattlefieldAttackModifier
extends Resource

@export var apply_to_self: bool = false
@export var is_attacked_triggered: bool = false
@export var immediate: bool = false
@export var turns: int = 0

# Returns true on skip turn
func execute(_player: BattlefieldPlayerEntity, _enemy: BattlefieldAIEntity,
		_additional_data: Dictionary) -> bool:
	return false
