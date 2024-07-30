class_name CheckpointMenuLayer2
extends CanvasLayer

@export var lore_panel: LorePanel
@export var lore_list: ItemList
@export var checkpoint: Checkpoint

@onready var lore_panel_shield: Panel = %LorePanelShield
@onready var map: Control = %Map

var pending_load: String = ""

func _ready() -> void:
	visibility_changed.connect(on_visibility_changed)
	checkpoint.checkpoint_interaction_ended.connect(on_interaction_ended)

	hide_all_parts()

func on_visibility_changed() -> void:
	if not is_visible():
		hide_all_parts()

func hide_all_parts() -> void:
	lore_panel.hide_all()
	lore_panel_shield.hide()
	lore_list.deselect_all()
	map.hide()

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

func _on_close_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	checkpoint.end_interaction()
	hide_all_parts()

func _on_lore_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	if lore_panel.is_visible_in_tree():
		hide_all_parts()
	else:
		hide_all_parts()
		lore_panel.start()
		lore_panel_shield.show()

func _on_shadows_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	hide_all_parts()
	hide()
	pending_load = "workbench"
	LevelManager.menu_unloaded.connect(on_menu_unloaded)
	MenuManager.fader_controller.translucent_to_black_complete.connect(on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()

func _on_fast_travel_pressed() -> void:
	if map.visible: return
	LevelManager.audio_anchor.play_sfx("accept_button")
	map.show()

func _on_close_lore_button_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	_on_lore_pressed()

func _on_map_fast_travel_started(_checkpoint_tag: String) -> void:
	hide_all_parts()
	hide()
