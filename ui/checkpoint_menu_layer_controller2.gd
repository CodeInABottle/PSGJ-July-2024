class_name CheckpointMenuLayer2
extends CanvasLayer

@export var slot_shadows_button: Button
@export var lore_panel: LorePanel
@export var lore_list: ItemList
@export var checkpoint: Checkpoint
@export var battle_button: Button
@export var fast_travel_button: Button
@export var fast_travel_map: FastTravelMap

var pending_load: String = ""

func _ready() -> void:
	slot_shadows_button.pressed.connect(on_slot_shadows_pressed)
	visibility_changed.connect(on_visibility_changed)
	checkpoint.checkpoint_interaction_ended.connect(on_interaction_ended)
	battle_button.pressed.connect(on_battle_pressed)
	fast_travel_button.pressed.connect(on_fast_travel_pressed)
	fast_travel_map.fast_travel_started.connect(on_fast_travel_started)

	hide_all_parts()

func on_slot_shadows_pressed() -> void:
	hide_all_parts()
	hide()
	pending_load = "workbench"
	LevelManager.menu_unloaded.connect(on_menu_unloaded)
	MenuManager.fader_controller.translucent_to_black_complete.connect(on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()

func on_battle_pressed() -> void:
	hide_all_parts()
	hide()
	pending_load = "battle"
	LevelManager.menu_unloaded.connect(on_menu_unloaded)
	LevelManager.trigger_battle("Mailbox", true)

func on_fast_travel_pressed() -> void:
	if fast_travel_map.is_visible_in_tree():
		fast_travel_map.hide()
	else:
		fast_travel_map.show()

func on_visibility_changed() -> void:
	if not is_visible():
		hide_all_parts()

func hide_all_parts() -> void:
	lore_panel.hide_all()
	lore_list.deselect_all()

func on_translucent_to_black_complete() -> void:
	if pending_load == "workbench":
		LevelManager.load_menu("workbench")

func on_black_to_translucent_complete() -> void:
	show()
	MenuManager.fader_controller.black_to_translucent_complete.disconnect(on_black_to_translucent_complete)

func on_interaction_ended() -> void:
	if MenuManager.fader_controller.translucent_to_black_complete.is_connected(on_translucent_to_black_complete):
		MenuManager.fader_controller.translucent_to_black_complete.disconnect(on_translucent_to_black_complete)

func on_menu_unloaded() -> void:
	if MenuManager.fader_controller.translucent_to_black_complete.is_connected(on_translucent_to_black_complete):
		MenuManager.fader_controller.translucent_to_black_complete.disconnect(on_translucent_to_black_complete)

	LevelManager.menu_unloaded.disconnect(on_menu_unloaded)

	MenuManager.fader_controller.black_to_translucent_complete.connect(on_black_to_translucent_complete)
	MenuManager.fader_controller.black_to_translucent()

	pending_load = ""

func on_fast_travel_started(_checkpoint_name: String) -> void:
	hide_all_parts()
	hide()

func _on_close_pressed() -> void:
	checkpoint.end_interaction()
	hide_all_parts()

func _on_lore_pressed() -> void:
	if lore_panel.is_visible_in_tree():
		hide_all_parts()
	else:
		hide_all_parts()
		lore_panel.start()
