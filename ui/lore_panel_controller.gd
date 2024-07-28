class_name LorePanel
extends PanelContainer

@export var lore_list: ItemList
@export var lore_name: Label
@export var lore_text: Label
@export var lore_details_panel: PanelContainer
@export var lore_author_label: Label

func _ready() -> void:
	lore_list.item_selected.connect(on_lore_selected)

func on_lore_selected(_index: int) -> void:
	update_lore_details()
	lore_details_panel.show()

func hide_all() -> void:
	lore_details_panel.hide()
	lore_author_label.hide()
	hide()

func update_lore_list() -> void:
	lore_list.clear()
	for item_name: String in PlayerStats.get_inventory_items():
		var item: InventoryItem = InventoryDatabase.get_item(item_name)
		if item is LoreItem:
			lore_list.add_item(item.item_name, item.item_icon)
	# Disable tooltips since you can't theme them
	for i: int in lore_list.item_count:
		lore_list.set_item_tooltip_enabled(i, false)

func update_lore_details() -> void:
	if lore_list.is_anything_selected():
		var selected_index: int = lore_list.get_selected_items()[0]
		var item: InventoryItem = InventoryDatabase.get_item(lore_list.get_item_text(selected_index))
		if item is LoreItem:
			lore_name.text = item.item_name
			lore_text.text = DialogueManager.dialogue_to_text(item.dialogue)
			if item.author_name != "":
				lore_author_label.text = item.author_name
				lore_author_label.show()
			else:
				lore_author_label.hide()

func start() -> void:
	update_lore_list()
	lore_details_panel.hide()
	show()
