class_name Interactable
extends Area2D

@export var can_quick_close: bool = true

signal interaction_started(interactable: Interactable)
signal interaction_ended(interactable: Interactable)
signal interaction_advanced(interactable: Interactable)
signal interaction_quick_closed(interactable: Interactable)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

# intialize interaction
func on_interacted_with() -> void:
	print("interacted with something!")
	interaction_started.emit(self)

# tell the control object the interaction has advanced
func advance_interaction() -> void:
	interaction_advanced.emit(self)

# tell the player the interaction has ended
func end_interaction() -> void:
	print("interaction with something ended..")
	interaction_ended.emit(self)

# returns whether the player can quick-close interaction
func quick_close_interaction() -> bool:
	if can_quick_close:
		interaction_quick_closed.emit()
		end_interaction()
		return true
	else:
		return false
