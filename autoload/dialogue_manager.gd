extends Node

var player_dialogue_ui: DialogueUI

signal dialogue_ended()

func play_dialogue(dialogue: Dialogue, content_key: String):
	if player_dialogue_ui:
		player_dialogue_ui.show_dialogue(dialogue, content_key)

func advance_dialogue() -> void:
	player_dialogue_ui.advance_dialogue()

func on_dialogue_ui_closed() -> void:
	dialogue_ended.emit()

func end_dialogue() -> void:
	player_dialogue_ui.end_dialogue()

# dialogue option callbacks
func test_callback() -> void:
	print("imagine dialogue triggering something")
