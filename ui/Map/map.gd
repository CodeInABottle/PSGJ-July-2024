extends Control

signal fast_travel_started(checkpoint_tag: String)

@onready var pins: Control = %Pins

var _pending_map_pin: MapPin = null

func _ready() -> void:
	for pin: MapPin in pins.get_children():
		assert(not pin.location.is_empty(), "You forgot to put the name on the map you dummy.")
		assert(not pin.checkpoint_tag.is_empty(), "You forgot to put the tag to the checkpoint you dummy.")
		pin.hide_all()
		pin.pressed.connect(_on_map_pin_pressed.bind(pin))
		_refresh_pin_statuses()

func _on_map_pin_pressed(map_pin: MapPin) -> void:
	MenuManager.fader_controller.translucent_to_black_complete.connect(_on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()
	_pending_map_pin = map_pin
	fast_travel_started.emit(map_pin.checkpoint_tag)

func _on_translucent_to_black_complete() -> void:
	MenuManager.fader_controller.translucent_to_black_complete.disconnect(_on_translucent_to_black_complete)
	LevelManager.fast_travel(_pending_map_pin.checkpoint_tag)

func _refresh_pin_statuses() -> void:
	for pin: MapPin in pins.get_children():
		if LevelManager.unlocked_checkpoints.has(pin.checkpoint_tag):
			pin.show()
		else:
			pin.hide()

func _on_close_pressed() -> void:
	hide()

func _on_visibility_changed() -> void:
	if visible and is_node_ready(): _refresh_pin_statuses()

