class_name DogNPC
extends BaseNPC

func wait_at_point(world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time = rng.randf_range(0.5, 5.0)
	var chance: float = rng.randf_range(0.0, 100.0)
	if chance < 50.0:
		pass
	else:
		npc_sprite.stop()
		npc_sprite.frame = 1
	await get_tree().create_timer(wait_time).timeout
