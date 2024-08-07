class_name CatNPC
extends BaseNPC

func wait_at_point(_world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time: float = rng.randf_range(0.5, 5.0)
	var chance: float = rng.randf_range(0.0, 100.0)
	if chance < 50.0:
		npc_sprite.play("wag")
	else:
		npc_sprite.play("idle")
	await get_tree().create_timer(wait_time).timeout

func on_battle_finished() -> void:
	LevelManager.menu_unloaded.disconnect(on_battle_finished)
	battle_finished.emit()
	MenuManager.fader_controller.fade_in()
	queue_free()
