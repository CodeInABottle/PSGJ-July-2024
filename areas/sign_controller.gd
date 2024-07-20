class_name Sign
extends InteractableHost

@export var dialogue: Dialogue

func on_interaction_started(interactable: Interactable) -> void:
	print("interacted with sign")
	DialogueManager.play_dialogue(dialogue, "main")
	DialogueManager.dialogue_ended.connect(end_interaction)

func on_interaction_advanced(interactable: Interactable) -> void:
	DialogueManager.advance_dialogue()
	
func end_interaction() -> void:
	interactable.end_interaction()
	_on_interaction_ended()
	
func on_interaction_quick_closed() -> void:
	DialogueManager.end_dialogue()

func _on_interaction_ended() -> void:
	print("interaction with sign ended")
	DialogueManager.dialogue_ended.disconnect(end_interaction)
