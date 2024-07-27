class_name MailboxNPC
extends BaseNPC

func wait_at_point(_world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time: float = rng.randf_range(0.5, 5.0)
	var chance: float = rng.randf_range(0.0, 100.0)
	if chance < 25.0:
		npc_sprite.play("flap_flag")
	elif chance < 50.0:
		npc_sprite.play("flap_door")
	elif chance < 75.0:
		npc_sprite.play("open")
	else:
		npc_sprite.play("closed")
	await get_tree().create_timer(wait_time).timeout
