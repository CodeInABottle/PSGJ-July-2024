class_name FerretNPC
extends BaseNPC

func wait_at_point(_world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time: float = rng.randf_range(0.5, 5.0)
	var chance: float = rng.randf_range(0.0, 100.0)
	if chance < 33.3:
		npc_sprite.play("jump")
	elif chance > 66.6:
		npc_sprite.play("head_bob")
	else:
		npc_sprite.stop()
		npc_sprite.frame = 3
	await get_tree().create_timer(wait_time).timeout
