class_name BattlefieldPlayerEntity
extends BattlefieldEntity

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func take_damage(damage_data: Dictionary) -> void:
	if damage_data["damage"] == 0: return

	animation_player.play("Hurt")
	entity_tracker.damage_taken.emit(true, damage_data)
	PlayerStats.health -= damage_data["damage"]

func heal(value: int) -> void:
	PlayerStats.health += value
