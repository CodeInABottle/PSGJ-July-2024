class_name CheckpointMenuLayer
extends CanvasLayer

@export var slot_shadows_button: Button
@export var hear_lore_button: Button
@export var shadows_panel: Panel
@export var shadows_list: ItemList
@export var shadow_slots_panel: Panel
@export var shadow_slots_list: ItemList
@export var shadow_details_button: Button
@export var shadow_confirm_button: Button
@export var shadow_details_close_button: Button
@export var shadow_details_panel: Panel
@export var shadow_preview: TextureRect
@export var menu_close_button: Button
@export var lore_panel: Panel
@export var lore_list: ItemList
@export var checkpoint: Checkpoint


func _ready() -> void:
	slot_shadows_button.pressed.connect(on_slot_shadows_pressed)
	hear_lore_button.pressed.connect(on_hear_lore_pressed)
	visibility_changed.connect(on_visibility_changed)
	
	shadow_slots_list.item_selected.connect(on_shadow_slot_selected)
	shadows_list.item_selected.connect(on_shadow_selected)
	shadow_details_button.pressed.connect(on_shadow_details_pressed)
	shadow_confirm_button.pressed.connect(on_shadow_confirm_pressed)
	shadow_details_close_button.pressed.connect(on_shadow_details_close_pressed)
	menu_close_button.pressed.connect(on_menu_close_pressed)
	
	hide_all_parts()

func on_menu_close_pressed() -> void:
	checkpoint.end_interaction()
	hide_all_parts()

func on_slot_shadows_pressed() -> void:
	var is_slot_active: bool = shadows_list.is_visible_in_tree()
	hide_all_parts()
	shadow_slots_panel.show()
	shadows_panel.set_visible(is_slot_active)

func on_hear_lore_pressed() -> void:
	hide_all_parts()
	lore_panel.show()

func on_shadow_slot_selected(index: int) -> void:
	shadows_panel.show()
	shadows_list.deselect_all()
	shadow_preview.set_texture(shadow_slots_list.get_item_icon(index))
	shadow_preview.show()

func on_shadow_selected(index: int) -> void:
	shadow_preview.set_texture(shadows_list.get_item_icon(index))
	shadow_preview.show()

func on_shadow_details_close_pressed() -> void:
	shadow_details_panel.hide()
	clear_shadow_details()

func clear_shadow_details() -> void:
	pass

func get_selected_shadow_index() -> int:
	var selected_index: int = -1
	if shadows_list.is_anything_selected():
		var selected_indices: PackedInt32Array = shadows_list.get_selected_items()
		selected_index = selected_indices[0]
	elif shadow_slots_list.is_anything_selected():
		var selected_indices: PackedInt32Array = shadow_slots_list.get_selected_items()
		selected_index = selected_indices[0]
	
	return selected_index

func on_shadow_details_pressed() -> void:
	var selected_index: int = get_selected_shadow_index()
	
	if selected_index != -1:
		set_shadow_details()
		shadow_details_panel.show()

func set_shadow_details() -> void:
	pass

func on_shadow_confirm_pressed() -> void:
	var selected_index: int = get_selected_shadow_index()
	
	if selected_index != -1:
		pass

func on_visibility_changed() -> void:
	if not is_visible():
		hide_all_parts()

func hide_all_parts() -> void:
	shadows_panel.hide()
	shadow_slots_panel.hide()
	shadow_preview.hide()
	lore_panel.hide()
	shadow_details_panel.hide()
	shadows_list.deselect_all()
	shadow_slots_list.deselect_all()
	lore_list.deselect_all()
