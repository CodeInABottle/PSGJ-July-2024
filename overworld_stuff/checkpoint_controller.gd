class_name Checkpoint
extends InteractableHost

signal checkpoint_interaction_ended()

@export var menu_layer: CanvasLayer
@export var checkpoint_name: String

@onready var shiny: Shiny = %Shiny
@onready var obelisk_sprite: AnimatedSprite2D = %ObeliskSprite

func _ready() -> void:
	interactable.interaction_started.connect(on_interaction_started)
	interactable.interaction_advanced.connect(on_interaction_advanced)
	interactable.interaction_quick_closed.connect(on_interaction_quick_closed)
	obelisk_sprite.animation_finished.connect(on_animation_finished)

func on_interaction_started(_interactable: Interactable) -> void:
	print("interacted with checkpoint")
	shiny.stop_shiny()
	menu_layer.show()
	obelisk_sprite.play()
	set_checkpoint()
	MenuManager.fader_controller.fade_to_translucent()
	PlayerStats.refill_health()
	LevelManager.reset_world()
	LevelManager.world_event_occurred.emit("checkpoint_touched", [])

func on_interaction_advanced(_interactable: Interactable) -> void:
	print("advanced checkpoint interaction")
	end_interaction()

func end_interaction() -> void:
	print("checkpoint interaction ended")
	interactable.end_interaction()
	_on_interaction_ended()

func on_interaction_quick_closed() -> void:
	print("checkpoint interaction quick-closed")
	_on_interaction_ended()

func _on_interaction_ended() -> void:
	shiny.show_shiny()
	menu_layer.hide()
	MenuManager.fader_controller.fade_from_translucent()
	checkpoint_interaction_ended.emit()
	obelisk_sprite.play()

func set_checkpoint() -> void:
	LevelManager.update_checkpoint(checkpoint_name)

func on_animation_finished() -> void:
	obelisk_sprite.frame = 0
