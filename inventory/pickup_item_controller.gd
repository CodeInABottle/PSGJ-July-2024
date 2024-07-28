class_name PickupItem
extends InteractableHost

signal pickup_interaction_ended(index: int)

@export var menu_layer: PickupLayer
@export var item_name: String
@export var item_sprite: Sprite2D
@export var quantity: int
@export var shiny: Shiny
@export var pickup_area: Area2D

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
	shiny.stop_shiny()
	menu_layer.update_info(item_name)
	menu_layer.reveal()
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
	menu_layer.disappear()
	MenuManager.fader_controller.fade_from_translucent_complete.connect(on_fade_from_translucent_complete)
	MenuManager.fader_controller.fade_from_translucent()
	pickup_interaction_ended.emit(get_index())
	get_parent().remove_child(self)

func on_continue_pressed() -> void:
	end_interaction()

func on_interact_pressed() -> void:
	pass

func on_fade_from_translucent_complete() -> void:
	MenuManager.fader_controller.fade_from_translucent_complete.disconnect(on_fade_from_translucent_complete)
	hide.call_deferred()
