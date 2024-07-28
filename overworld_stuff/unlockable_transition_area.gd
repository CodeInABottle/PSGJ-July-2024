class_name UnlockableTransitionArea
extends TransitionArea

@export var unlock_event_name: String
@export var unlock_item_name: String

var _is_unlocked: bool = false

func _ready() -> void:
	body_entered.connect(_on_player_entered)
	LevelManager.world_event_occurred.connect(on_world_event)
	PlayerStats.save_loaded.connect(refresh_unlock)

func refresh_unlock() -> void:
	var player_items: Dictionary = PlayerStats.get_inventory_items()
	if PlayerStats.save_loaded.is_connected(refresh_unlock):
		PlayerStats.save_loaded.disconnect(refresh_unlock)
	if player_items.keys().has(unlock_item_name):
		LevelManager.world_event_occurred.disconnect(on_world_event)
		_is_unlocked = true

func on_world_event(event_name: String, _args: Array) -> void:
	if event_name == unlock_event_name:
		_is_unlocked = true
		LevelManager.world_event_occurred.disconnect(on_world_event)

func _on_player_entered(entered_body: Node2D) -> void:
	if entered_body.is_in_group("player") and _is_unlocked:
		fader_controller = get_node("/root/Main/FaderLayer")
		fader_controller.fade_out_complete.connect(on_fade_out_complete)
		fader_controller.fade_out()
