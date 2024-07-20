class_name BattlefieldPlayerEntity
extends BattlefieldEntity

func take_damage(damage_data: Dictionary) -> void:
	entity_tracker.damage_taken.emit(true, damage_data)
	PlayerStats.health -= damage_data["damage"]

func _update_health(value: int) -> void:
	PlayerStats.health += value
