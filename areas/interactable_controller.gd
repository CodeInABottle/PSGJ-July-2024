class_name Interactable
extends Area2D

signal interaction_started(interactable: Interactable)
signal interaction_ended(interactable: Interactable)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func on_interacted_with() -> void:
	interaction_started.emit(self)

func on_interaction_ended() -> void:
	interaction_ended.emit(self)
