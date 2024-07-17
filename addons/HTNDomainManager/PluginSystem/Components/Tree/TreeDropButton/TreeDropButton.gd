@tool
class_name TreeDropButton
extends MarginContainer

const TREE_ITEM = preload("res://addons/HTNDomainManager/PluginSystem/Components/Tree/TreeItem/tree_item.tscn")

@onready var button: Button = %Button
@onready var sub_buttons: VBoxContainer = %SubButtons

func _ready() -> void:
	sub_buttons.hide()

func set_title(title: String) -> void:
	button.text = title

func add_menu_item(item_name: String, callback: Callable) -> void:
	if _has(item_name): return

	var tree_item_instance: TreeItemButton = TREE_ITEM.instantiate()
	sub_buttons.add_child(tree_item_instance)
	tree_item_instance.initialize(item_name, callback)

func show_all() -> void:
	for tree_item: TreeItemButton in sub_buttons.get_children():
		tree_item.show()
	show()

func filter(filter_words: Array) -> void:
	var has_children_shown: bool = false
	for tree_item: TreeItemButton in sub_buttons.get_children():
		if filter_words.is_empty():
			tree_item.show()
			has_children_shown = true
			continue

		if tree_item.label.text in filter_words:
			tree_item.show()
			has_children_shown = true
		else:
			tree_item.hide()

	if not has_children_shown:
		hide()
	else:
		show()
	button.button_pressed = has_children_shown

func _has(item_name: String) -> bool:
	for tree_item: TreeItemButton in sub_buttons.get_children():
		if tree_item.label.text.to_lower() == item_name.to_lower():
			return true
	return false

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sub_buttons.show()
	else:
		sub_buttons.hide()
