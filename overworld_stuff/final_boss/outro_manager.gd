extends Node

func _ready() -> void:
	LevelManager.world_event_occurred.connect(_on_world_event)

func _on_world_event(world_event_name: String, args: Array) -> void:
	if world_event_name == "battle_finished":
		if args[0]["shadow_name"] == "Shadow" and args[0]["captured"]:
			trigger_outro()

func trigger_outro() -> void:
	PlayerStats.player.hint_manager.hint_ended.connect(on_hint_ended)
	PlayerStats.player.hint_manager.play_quip("thanks_for_playing")

func on_hint_ended() -> void:
	PlayerStats.player.hint_manager.hint_ended.disconnect(on_hint_ended)
	LevelManager.load_world("main_menu")
