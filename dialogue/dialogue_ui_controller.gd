class_name DialogueUI
extends Control

@export var dialogue_label: Label
@export var next_button: Button
@export var close_button: Button
@export var button_container: GridContainer
@export var letter_timer: Timer
@export var speaker_icon: TextureRect
@export var speaker_name_label: Label

var current_dialogue: Dialogue

var current_dialogue_block: DialogueBlock
var current_dialogue_block_index: int = 0

var current_dialogue_line: DialogueLine
var current_dialogue_line_index: int = 0
var current_dialogue_string: String

var letter_index: int = 0

const SPEAKING_DISTANCE_THRESHOLD: float = 5.0
const LETTER_TIME: float = 0.05
const SPACE_TIME: float = 0.08
const PUNCTUATION_TIME: float = 0.2

signal dialogue_ui_closed()

const OPTION_TEXT_SIZE: int = 230
const NORMAL_TEXT_SIZE: int = 370

func _ready() -> void:
	DialogueManager.player_dialogue_ui = self
	make_ui_connections()


func make_ui_connections() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	letter_timer.timeout.connect(_on_timeout)
	dialogue_ui_closed.connect(DialogueManager.on_dialogue_ui_closed)

func show_dialogue(dialogue: Dialogue, content_key: String) -> void:
	var dialogue_block_index: int = dialogue.content_keys.find(content_key)
	if not dialogue_block_index == -1:
		show()

		current_dialogue = dialogue
		current_dialogue_block_index = dialogue_block_index
		current_dialogue_block = current_dialogue.contents[current_dialogue_block_index]
		current_dialogue_line_index = -1
		continue_dialogue()

func hide_dialog() -> void:
	hide()

func continue_dialogue() -> void:
	clear_buttons()
	next_button.hide()
	current_dialogue_line_index += 1
	if current_dialogue_line_index <= current_dialogue_block.block_lines.size() - 1:
		dialogue_label.set_custom_minimum_size(Vector2i(NORMAL_TEXT_SIZE, 0))
		current_dialogue_line = current_dialogue_block.block_lines[current_dialogue_line_index]
		current_dialogue_string = current_dialogue_line.line_text
		display_text()

		if current_dialogue_line is DialogueOption:
			dialogue_label.set_custom_minimum_size(Vector2i(OPTION_TEXT_SIZE, 0))
			var options: Array[String] = current_dialogue_line.options
			var callbacks: Array[String] = current_dialogue_line.callbacks
			var option_index: int = 0
			for option: String in options:
				var new_button: Button = Button.new()
				new_button.text = option
				button_container.add_child(new_button)

				if callbacks[option_index] != "":
					if DialogueManager.has_method(callbacks[option_index]):
						var callback_callable: Callable = Callable(DialogueManager, callbacks[option_index])
						new_button.pressed.connect(callback_callable)

				option_index += 1

	else:
		clear_current_dialog()

func advance_dialogue() -> void:
	if not current_dialogue == null:
		if letter_index > current_dialogue_line.line_text.length() - 1:
			continue_dialogue()
		else:
			letter_timer.stop()
			dialogue_label.text = current_dialogue_line.line_text
			letter_index = 99999999999
			if current_dialogue_line_index + 1 < current_dialogue_block.block_lines.size():
				next_button.show()

func _on_next_button_pressed() -> void:
	continue_dialogue()

func _on_close_button_pressed() -> void:
	end_dialogue()

func end_dialogue() -> void:
	if not current_dialogue == null:
		letter_timer.stop()
		clear_current_dialog()

func clear_current_dialog() -> void:
	current_dialogue = null
	current_dialogue_block_index = 0
	current_dialogue_block = null
	current_dialogue_line_index = 0
	current_dialogue_line = null
	letter_timer.stop()
	clear_buttons()

	dialogue_label.text = ""
	hide_dialog()
	dialogue_ui_closed.emit()

func clear_buttons() -> void:
	var buttons: Array = button_container.get_children()
	for button: Button in buttons:
		button.queue_free()

func display_text() -> void:
	dialogue_label.text = ""
	letter_index = 0
	display_letter()

func display_letter() -> void:
	if letter_index <= current_dialogue_line.line_text.length() - 1:
		dialogue_label.text += current_dialogue_line.line_text[letter_index]

		match current_dialogue_line.line_text[letter_index]:
			"!", "?", ".", ",", ";":
				letter_timer.start(PUNCTUATION_TIME)
			" ":
				letter_timer.start(SPACE_TIME)
			_:
				letter_timer.start(LETTER_TIME)

		letter_index += 1
	elif current_dialogue_line_index + 1 < current_dialogue_block.block_lines.size():
		next_button.show()

func _on_timeout() -> void:
	display_letter()
