extends Control

@export var save_button: Button
@export var respawn_button: Button
@export var bag_button: Button
@export var item_list: ItemList
@export var item_name_label: Label
@export var item_icon: TextureRect
@export var item_description: Label
@export var interact_button: Button
@export var items_panel: PanelContainer
@export var details_panel: PanelContainer

func _ready() -> void:
	MenuManager.pause_menu = self
	save_button.pressed.connect(on_save_pressed)
	respawn_button.pressed.connect(on_respawn_pressed)
	bag_button.pressed.connect(on_bag_button_pressed)
	interact_button.pressed.connect(on_bag_button_pressed)
	item_list.item_selected.connect(on_item_selected)

func on_save_pressed() -> void:
	hide_all()
	print(SaveManager.generate_save_string())

func on_respawn_pressed() -> void:
	MenuManager.fader_controller.translucent_to_black_complete.connect(on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()

func on_translucent_to_black_complete() -> void:
	MenuManager.toggle_pause_no_fade()
	MenuManager.fader_controller.translucent_to_black_complete.disconnect(on_translucent_to_black_complete)
	LevelManager.respawn()

func on_bag_button_pressed() -> void:
	if items_panel.is_visible_in_tree():
		hide_all()
	else:
		populate_item_list()
		items_panel.show()

func on_item_selected(index: int) -> void:
	update_details()
	details_panel.show()
	
func on_interact_button_pressed() -> void:
	pass

func hide_all() -> void:
	item_list.deselect_all()
	items_panel.hide()
	details_panel.hide()
	interact_button.hide()

func update_details() -> void:
	interact_button.hide()
	if item_list.is_anything_selected():
		var selected_item_index = item_list.get_selected_items()[0]
		var item: InventoryItem = InventoryDatabase.get_item(item_list.get_item_text(selected_item_index))
		item_name_label.text = item.item_name
		item_icon.texture = item.item_icon
		item_description.text = item.item_description
		
		if item is LoreItem:
			#interact_button.show()
			pass

func populate_item_list() -> void:
	item_list.clear()
	for item_name: String in PlayerStats.invetory_items:
		var item: InventoryItem = InventoryDatabase.get_item(item_name)
		for index: int in range(PlayerStats.invetory_items[item_name]):
			item_list.add_item(item.item_name, item.item_icon)


