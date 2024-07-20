class_name BattlefieldEntity
extends Node2D

@export var entity_tracker: BattlefieldEntityTracker

func regen_ap() -> void:
	pass

func take_damage(_damage_data: Dictionary) -> void:
	pass

func _update_health(_value: int) -> void:
	pass
