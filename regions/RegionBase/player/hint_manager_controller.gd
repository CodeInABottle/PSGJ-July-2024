class_name HintManager
extends Node

var _hint_active: bool = false

func close_hint() -> void:
	if _hint_active:
		DialogueManager.end_dialogue()
		on_hint_ended()

func play_hint(hint_dialogue: Dialogue) -> void:
	_hint_active = true
	DialogueManager.play_dialogue(hint_dialogue, "main")
	DialogueManager.dialogue_ended.connect(on_hint_ended)

func advance_hint() -> void:
	if _hint_active:
		DialogueManager.advance_dialogue()

func on_hint_ended() -> void:
	_hint_active = false
	DialogueManager.dialogue_ended.disconnect(on_hint_ended)
