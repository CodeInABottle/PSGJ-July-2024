class_name TreeNPC
extends BaseNPC

func wait_at_point(_world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time: float = rng.randf_range(0.5, 5.0)
	npc_sprite.play("idle")
	await get_tree().create_timer(wait_time).timeout
