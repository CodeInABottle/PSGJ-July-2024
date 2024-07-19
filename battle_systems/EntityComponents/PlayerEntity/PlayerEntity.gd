class_name BattlefieldPlayerEntity
extends BattlefieldEntity

@export var speed: int = 10

func get_speed() -> int:
	return speed

func _update_health(value: int) -> void:
	PlayerStats.health += value
