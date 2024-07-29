class_name PickupKeyItem
extends PickupItem

var _pickup_event_name: String

func _ready() -> void:
	interactable.interaction_started.connect(on_interaction_started)
	interactable.interaction_advanced.connect(on_interaction_advanced)
	interactable.interaction_quick_closed.connect(on_interaction_quick_closed)
	menu_layer.continue_pressed.connect(on_continue_pressed)
	menu_layer.interact_pressed.connect(on_interact_pressed)
	menu_layer.interact_button.text = "READ"
	update_sprite()
	update_key_info()

func _on_interaction_ended() -> void:
	menu_layer.disappear()
	MenuManager.fader_controller.fade_from_translucent_complete.connect(on_fade_from_translucent_complete)
	MenuManager.fader_controller.fade_from_translucent()
	pickup_interaction_ended.emit(index)
	PlayerStats.add_item(item_name, quantity)
	world_event()
	get_parent().remove_child(self)

func world_event() -> void:
	if _pickup_event_name != "":
		LevelManager.world_event_occurred.emit(_pickup_event_name, [])

func update_key_info() -> void:
	var item: KeyItem = InventoryDatabase.get_item(item_name)
	_pickup_event_name = item.pickup_event_name
