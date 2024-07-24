class_name PickupItem
extends InteractableHost

signal pickup_interaction_ended()

@export var menu_layer: PickupLayer
@export var item_name: String
@export var item_sprite: Sprite2D
@export var quantity: int

func _ready() -> void:
	interactable.interaction_started.connect(on_interaction_started)
	interactable.interaction_advanced.connect(on_interaction_advanced)
	interactable.interaction_quick_closed.connect(on_interaction_quick_closed)
	menu_layer.continue_pressed.connect(on_continue_pressed)
	menu_layer.interact_pressed.connect(on_interact_pressed)
	menu_layer.interact_button.text = "READ"
	update_sprite()

func update_sprite() -> void:
	var item: InventoryItem = InventoryDatabase.get_item(item_name)
	item_sprite.texture = item.item_icon

func on_interaction_started(_interactable: Interactable) -> void:
	print("interacted with pickup item")
	menu_layer.update_info(item_name)
	menu_layer.show()
	MenuManager.fader_controller.fade_to_translucent()

func on_interaction_advanced(_interactable: Interactable) -> void:
	print("pickup item interaction advanced")
	end_interaction()

func end_interaction() -> void:
	print("pickup interaction ended")
	interactable.end_interaction()
	PlayerStats.add_item(item_name, quantity)
	_on_interaction_ended()

func on_interaction_quick_closed() -> void:
	print("pickup interaction quick-closed")
	PlayerStats.add_item(item_name, quantity)
	_on_interaction_ended()

func _on_interaction_ended() -> void:
	menu_layer.hide()
	MenuManager.fader_controller.fade_from_translucent()
	pickup_interaction_ended.emit()
	queue_free()

func on_continue_pressed() -> void:
	end_interaction()

func on_interact_pressed() -> void:
	pass
