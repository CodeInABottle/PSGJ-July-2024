class_name PickupItem
extends InteractableHost

signal pickup_interaction_ended()

@export var menu_layer: PickupLayer
@export var item_name: String
@export var item_sprite: Sprite2D
@export var quantity: int
@export var pickup_area: Area2D
@export var shiny_area: Area2D
@export var shiny_sprite: Sprite2D

@onready var shiny_player: AnimationPlayer = shiny_sprite.get_child(0)
@onready var fade_timer: Timer = %FadeTimer

func _ready() -> void:
	interactable.interaction_started.connect(on_interaction_started)
	interactable.interaction_advanced.connect(on_interaction_advanced)
	interactable.interaction_quick_closed.connect(on_interaction_quick_closed)
	shiny_area.body_entered.connect(on_body_entered_area)
	shiny_area.body_exited.connect(on_body_exited_area)
	fade_timer.timeout.connect(on_fade_timer_timeout)
	menu_layer.continue_pressed.connect(on_continue_pressed)
	menu_layer.interact_pressed.connect(on_interact_pressed)
	menu_layer.interact_button.text = "READ"
	update_sprite()

func update_sprite() -> void:
	var item: InventoryItem = InventoryDatabase.get_item(item_name)
	item_sprite.texture = item.item_icon

func on_interaction_started(_interactable: Interactable) -> void:
	stop_shiny()
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
	pickup_interaction_ended.emit()
	pickup_area.hide()
	item_sprite.hide()
	
func on_continue_pressed() -> void:
	end_interaction()

func on_interact_pressed() -> void:
	pass

func on_fade_from_translucent_complete() -> void:
	MenuManager.fader_controller.fade_from_translucent_complete.disconnect(on_fade_from_translucent_complete)
	queue_free.call_deferred()

func on_body_entered_area(entered_body: Node2D) -> void:
	if entered_body.is_in_group("player"):
		shiny_sprite.show()
		shiny_player.play("bounce")
		var shiny_tween: Tween = shiny_sprite.create_tween()
		shiny_tween.tween_property(shiny_sprite, "modulate", Color(1,1,1,1), 0.5)

func on_body_exited_area(exited_body: Node2D) -> void:
	if exited_body.is_in_group("player"):
		stop_shiny.call_deferred()

func on_fade_timer_timeout() -> void:
	shiny_sprite.hide()
	shiny_player.stop()

func stop_shiny() -> void:
	var shiny_tween: Tween = shiny_sprite.create_tween()
	shiny_tween.tween_property(shiny_sprite, "modulate", Color(1,1,1,0), 0.5)
	fade_timer.start()
