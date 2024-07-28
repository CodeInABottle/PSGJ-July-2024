class_name HintManager
extends Node

var _hint_active: bool = false

@export var hint_icon: Texture2D

func close_hint() -> void:
	if _hint_active:
		DialogueManager.end_dialogue()
		on_hint_ended()

func play_hint(hint_dialogue: Dialogue) -> void:
	if not _hint_active:
		_hint_active = true
		DialogueManager.play_dialogue(hint_dialogue, "main", "Hint", hint_icon)
		DialogueManager.dialogue_ended.connect(on_hint_ended)

func advance_hint() -> void:
	if _hint_active:
		DialogueManager.advance_dialogue()

func on_hint_ended() -> void:
	_hint_active = false
	DialogueManager.dialogue_ended.disconnect(on_hint_ended)
