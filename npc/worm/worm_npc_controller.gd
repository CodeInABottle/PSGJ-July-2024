class_name WormNPC
extends BaseNPC

func wait_at_point(_world_state: Dictionary) -> void:
	var wait_time: float = 0.0
	await get_tree().create_timer(wait_time).timeout
