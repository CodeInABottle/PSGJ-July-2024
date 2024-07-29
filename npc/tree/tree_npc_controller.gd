class_name TreeNPC
extends BaseNPC

func wait_at_point(_world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time: float = 0.0
	if _has_been_defeated:
		wait_time = rng.randf_range(5.0, 30.0)
	else:
		wait_time = rng.randf_range(0.0, 0.5)
	npc_sprite.play("idle")
	await get_tree().create_timer(wait_time).timeout
