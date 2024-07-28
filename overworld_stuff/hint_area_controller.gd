class_name HintArea
extends Area2D

@export_enum("None", "Item", "Shadow") var delete_mode: String = "None"
@export var hint_dialogue: Dialogue
@export var delete_name: String

func _ready() -> void:
	body_entered.connect(on_body_entered)
	LevelManager.world_event_occurred.connect(on_world_event)

	if SaveManager.load_pending:
		PlayerStats.save_loaded.connect(check_for_delete)
	else:
		check_for_delete()

func on_body_entered(entered_body: Node2D) -> void:
	if entered_body is Player:
		entered_body.play_hint(hint_dialogue)

func check_for_delete() -> void:
	match delete_mode:
		"Item":
			var inventory_items: Dictionary = PlayerStats.get_inventory_items()
			if inventory_items.keys().has(delete_name):
				queue_free()
		"Shadow":
			var unlocked_shadows: PackedStringArray = PlayerStats.get_all_unlocked_shadows()
			if unlocked_shadows.has(delete_name):
				queue_free()

	if PlayerStats.save_loaded.is_connected(check_for_delete):
		PlayerStats.save_loaded.disconnect(check_for_delete)

func on_world_event(event_name:String, args:Array) -> void:
	if event_name == "battle_finished" and delete_mode == "Shadow":
		if args[0]["shadow_name"] == delete_name:
			queue_free()
	elif event_name == "item_get:"+delete_name and delete_mode == "Item":
		queue_free()
