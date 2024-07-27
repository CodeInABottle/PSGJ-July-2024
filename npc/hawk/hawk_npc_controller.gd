class_name HawkNPC
extends BaseNPC

func wait_at_point(_world_state: Dictionary) -> void:
	var wait_time: float = 0.0
	await get_tree().create_timer(wait_time).timeout

func walk_to_point(world_state: Dictionary) -> void:
	npc_sprite.play("walk", 1.0)
	if not world_state["close_enough_to_point"]:
		var next_path_point: Vector2 = nav.get_next_path_position()
		var desired_direction: Vector2 = global_position.direction_to(next_path_point)
		npc_sprite.rotation = desired_direction.angle() + PI
		velocity = velocity.lerp(desired_direction * npc_speed, _delta * LERP_SCALE)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func chase_player(_world_state: Dictionary) -> void:
	_has_wander_point = false
	nav.set_target_position(PlayerStats.player.get_global_position())
	var next_path_point: Vector2 = nav.get_next_path_position()
	var desired_direction: Vector2 = global_position.direction_to(next_path_point)
	npc_sprite.rotation = desired_direction.angle() + PI
	velocity = velocity.lerp(desired_direction * npc_speed, _delta * LERP_SCALE)
	npc_sprite.play("walk", 1.0)
	
	move_and_slide()
