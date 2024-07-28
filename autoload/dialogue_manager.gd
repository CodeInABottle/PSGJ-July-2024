extends Node

var player_dialogue_ui: DialogueUI

signal dialogue_started()
signal dialogue_ended()

func play_dialogue(dialogue: Dialogue, content_key: String, speaker_name: String = "", speaker_icon: Texture2D = null) -> void:
	if player_dialogue_ui:
		if speaker_name != "":
			player_dialogue_ui.speaker_name_label.text = speaker_name
		
		if speaker_icon != null:
			player_dialogue_ui.speaker_icon.texture = speaker_icon
		
		dialogue_started.emit()
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

func dialogue_to_text(dialogue: Dialogue, content_key: String = "main") -> String:
	var block_index: int = dialogue.content_keys.find(content_key)
	var dialogue_text: String = "ERROR: FAILED"
	if block_index != -1:
		var dialogue_block: DialogueBlock = dialogue.contents[block_index]
		dialogue_text = ""
		for line: DialogueLine in dialogue_block.block_lines:
			dialogue_text = dialogue_text + line.line_text + "\n\n"
		
	return dialogue_text
