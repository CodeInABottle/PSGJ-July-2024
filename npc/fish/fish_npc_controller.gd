class_name FishNPC
extends BaseNPC

func wait_at_point(world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time = rng.randf_range(0.5, 5.0)
	await get_tree().create_timer(wait_time).timeout
