class_name Mom
extends Sign

@onready var mom_sprite: Sprite2D = %Sprite2D

func on_interaction_started(_interactable: Interactable) -> void:
	shiny.stop_shiny()
	DialogueManager.play_dialogue(dialogue, "main", "Mom", mom_sprite.texture)
	DialogueManager.dialogue_ended.connect(end_interaction)

func on_interaction_advanced(_interactable: Interactable) -> void:
	DialogueManager.advance_dialogue()

func end_interaction() -> void:
	interactable.end_interaction()
	_on_interaction_ended()

func on_interaction_quick_closed() -> void:
	DialogueManager.end_dialogue()

func _on_interaction_ended() -> void:
	shiny.show_shiny()
	DialogueManager.dialogue_ended.disconnect(end_interaction)
