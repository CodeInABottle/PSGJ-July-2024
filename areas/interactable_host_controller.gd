class_name InteractableHost
extends StaticBody2D

@export var interactable: Interactable

func _ready() -> void:
	interactable.interaction_started.connect(on_interaction_started)
	interactable.interaction_advanced.connect(on_interaction_advanced)
	interactable.interaction_quick_closed.connect(on_interaction_quick_closed)

func on_interaction_started(_interactable: Interactable) -> void:
	pass

func on_interaction_advanced(_interactable: Interactable) -> void:
	end_interaction()

func end_interaction() -> void:
	interactable.end_interaction()
	_on_interaction_ended()

func on_interaction_quick_closed() -> void:
	_on_interaction_ended()

func _on_interaction_ended() -> void:
	pass
