class_name Sign
extends InteractableHost

@export var dialogue: Dialogue

@onready var shiny: Shiny = %Shiny

func on_interaction_started(_interactable: Interactable) -> void:
	print("interacted with sign")
	shiny.stop_shiny()
	DialogueManager.play_dialogue(dialogue, "main")
	DialogueManager.dialogue_ended.connect(end_interaction)

func on_interaction_advanced(_interactable: Interactable) -> void:
	DialogueManager.advance_dialogue()
	
func end_interaction() -> void:
	interactable.end_interaction()
	_on_interaction_ended()
	
func on_interaction_quick_closed() -> void:
	DialogueManager.end_dialogue()

func _on_interaction_ended() -> void:
	print("interaction with sign ended")
	shiny.show_shiny()
	DialogueManager.dialogue_ended.disconnect(end_interaction)
