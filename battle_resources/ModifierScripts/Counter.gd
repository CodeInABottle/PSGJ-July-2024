class_name BattlefieldCounterMod
extends BattlefieldAttackModifier

@export var counter_damage: int = 0
@export var full_counter: bool = false

# Returns true on skip turn
func execute(tracker: BattlefieldEntityTracker, additional_data: Dictionary) -> bool:
	var damage: int = counter_damage
	if full_counter:
		damage = additional_data["damage"]
	var damage_data: Dictionary = {
		"damage": damage,
		"resonate_type": additional_data["resonate_type"],
		"components": additional_data["components"]
	}
	# The entity that has the attack phase takes the damage
	if additional_data["created_by_player"]:
		tracker.enemy_entity.take_damage(damage_data)
	else:
		tracker.player_entity.take_damage(damage_data)

	return false
