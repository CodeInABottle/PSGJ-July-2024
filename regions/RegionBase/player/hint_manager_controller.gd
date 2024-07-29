class_name HintManager
extends Node

var _hint_active: bool = false

@export var hint_icon: Texture2D
@export var quips: Dialogue

func _ready() -> void:
	LevelManager.world_event_occurred.connect(on_world_event)

func close_hint() -> void:
	if _hint_active:
		DialogueManager.end_dialogue()
		on_hint_ended()

func play_hint(hint_dialogue: Dialogue, content_key: String = "main") -> void:
	if not _hint_active:
		_hint_active = true
		DialogueManager.play_dialogue(hint_dialogue, content_key, "Hint", hint_icon)
		DialogueManager.dialogue_ended.connect(on_hint_ended)

func advance_hint() -> void:
	if _hint_active:
		DialogueManager.advance_dialogue()

func on_hint_ended() -> void:
	_hint_active = false
	DialogueManager.dialogue_ended.disconnect(on_hint_ended)

func is_hint_active() -> bool:
	return _hint_active

func on_world_event(world_event_name: String, args:Array) -> void:
	if world_event_name == "battle_finished":
		if args[0]["shadow_name"] == "Mailbox" and args[0]["captured"]:
			play_quip("mailbox")

func play_quip(quip_key: String) -> void:
	if quips.content_keys.has(quip_key):
		play_hint(quips, quip_key)
