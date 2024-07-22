class_name CheckpointMenuLayer2
extends CanvasLayer

@export var slot_shadows_button: Button
@export var hear_lore_button: Button
@export var menu_close_button: Button
@export var lore_panel: Panel
@export var lore_list: ItemList
@export var checkpoint: Checkpoint


func _ready() -> void:
	slot_shadows_button.pressed.connect(on_slot_shadows_pressed)
	hear_lore_button.pressed.connect(on_hear_lore_pressed)
	visibility_changed.connect(on_visibility_changed)
	checkpoint.checkpoint_interaction_ended.connect(on_interaction_ended)
	
	menu_close_button.pressed.connect(on_menu_close_pressed)
	
	hide_all_parts()

func on_menu_close_pressed() -> void:
	checkpoint.end_interaction()
	hide_all_parts()

func on_slot_shadows_pressed() -> void:
	hide_all_parts()
	hide()
	
	LevelManager.menu_unloaded.connect(on_menu_unloaded)
	MenuManager.fader_controller.translucent_to_black_complete.connect(on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()
	

func on_hear_lore_pressed() -> void:
	hide_all_parts()
	lore_panel.show()

func on_visibility_changed() -> void:
	if not is_visible():
		hide_all_parts()

func hide_all_parts() -> void:
	lore_panel.hide()
	lore_list.deselect_all()

func on_translucent_to_black_complete() -> void:
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
	
	
