class_name PickupLayer
extends CanvasLayer

@export var continue_button: Button
@export var interact_button: Button
@export var name_label: Label
@export var description_label: Label
@export var icon_rect: TextureRect

signal continue_pressed()
signal interact_pressed()

func _ready() -> void:
	continue_button.pressed.connect(on_continue_pressed)
	interact_button.pressed.connect(on_interact_pressed)

func on_continue_pressed() -> void:
	continue_pressed.emit()

func on_interact_pressed() -> void:
	interact_pressed.emit()

func update_info(item_name: String) -> void:
	var item: InventoryItem = InventoryDatabase.get_item(item_name)
	if item:
		name_label.text = item.item_name
		description_label.text = item.item_description
		icon_rect.texture = item.item_icon
