class_name PickupLore
extends PickupItem

@onready var dialogue_timer: Timer = %DialogueTimer

var in_dialogue: bool = false

func on_interaction_started(_interactable: Interactable) -> void:
	LevelManager.world_event_occurred.emit("item_get:"+item_name, [])
	DialogueManager.end_dialogue()
	shiny.stop_shiny()
	menu_layer.update_info(item_name)
	menu_layer.reveal()
	menu_layer.interact_button.show()
	MenuManager.fader_controller.fade_to_translucent()

func on_interact_pressed() -> void:
	if not in_dialogue:
		DialogueManager.dialogue_ended.connect(on_dialogue_ended)
		dialogue_timer.timeout.connect(on_dialogue_timer_timeout)
		dialogue_timer.start()
		menu_layer.hide_menu()
		in_dialogue = true

func on_interaction_advanced(_interactable: Interactable) -> void:
	if not in_dialogue:
		end_interaction()
	else:
		DialogueManager.advance_dialogue()

func on_interaction_quick_closed() -> void:
	print("pickup interaction quick-closed")
	_on_interaction_ended()

func _on_interaction_ended() -> void:
	menu_layer.disappear()
	if in_dialogue:
		DialogueManager.end_dialogue()
	MenuManager.fader_controller.fade_from_translucent_complete.connect(on_fade_from_translucent_complete)
	MenuManager.fader_controller.fade_from_translucent()
	PlayerStats.add_item(item_name, quantity)
	pickup_interaction_ended.emit(index)
	get_parent().remove_child(self)

func on_dialogue_ended() -> void:
	DialogueManager.dialogue_ended.disconnect(on_dialogue_ended)
	in_dialogue = false
	menu_layer.show_menu()

func on_dialogue_timer_timeout() -> void:
	dialogue_timer.timeout.disconnect(on_dialogue_timer_timeout)
	var item: LoreItem = InventoryDatabase.get_item(item_name)
	DialogueManager.play_dialogue(item.dialogue, "main", item.author_name, item.item_icon)

func on_fade_from_translucent_complete() -> void:
	MenuManager.fader_controller.fade_from_translucent_complete.disconnect(on_fade_from_translucent_complete)
	hide.call_deferred()
	
