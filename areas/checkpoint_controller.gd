class_name Checkpoint
extends InteractableHost

@export var menu_layer: CanvasLayer
@export var checkpoint_name: String

func _ready():
	interactable.interaction_started.connect(on_interaction_started)
	interactable.interaction_advanced.connect(on_interaction_advanced)
	interactable.interaction_quick_closed.connect(on_interaction_quick_closed)

func on_interaction_started(interactable: Interactable) -> void:
	print("interacted with checkpoint")
	menu_layer.show()
	set_checkpoint()
	MenuManager.fader_controller.fade_to_translucent()

func on_interaction_advanced(interactable: Interactable) -> void:
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
	menu_layer.hide()
	MenuManager.fader_controller.fade_from_translucent()

func set_checkpoint() -> void:
	LevelManager.update_checkpoint(checkpoint_name)
