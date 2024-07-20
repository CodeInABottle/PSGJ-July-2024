class_name BattlefieldPlayerEntity
extends BattlefieldEntity

func _update_health(value: int) -> void:
	PlayerStats.health += value

func take_damage(amount: int) -> void:
	PlayerStats.health -= amount
