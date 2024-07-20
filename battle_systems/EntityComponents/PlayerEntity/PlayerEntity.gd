class_name BattlefieldPlayerEntity
extends BattlefieldEntity

func take_damage(damage_data: Dictionary) -> void:
	PlayerStats.health -= damage_data["damage"]
	entity_tracker.damage_taken.emit(true)

func _update_health(value: int) -> void:
	PlayerStats.health += value
