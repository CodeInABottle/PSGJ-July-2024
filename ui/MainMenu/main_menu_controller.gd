extends Control

@onready var control_shield: Control = %ControlShield
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var save_string_edit: LineEdit = %SaveStringEdit
@onready var load_confirm: Button = %LoadConfirm
@onready var menu_buttons: Control = %MenuButtons
@onready var save_string_container: Control = %SaveStringContainer

var _fader_controller: CanvasLayer
var _save_string: String

func _ready() -> void:
	_fader_controller = get_node("/root/Main/FaderLayer")
	_fader_controller.fade_out_complete.connect(_on_fade_out_complete)
	control_shield.hide()
	menu_buttons.show()
	save_string_container.show()

func _on_fade_out_complete() -> void:
	_fader_controller.fade_out_complete.disconnect(_on_fade_out_complete)
	SaveManager.generate_scene_from_string(_save_string)

func _on_play_pressed() -> void:
	_save_string = ""
	_fader_controller.fade_out()

func _on_load_pressed() -> void:
	animation_player.play("SlideMainButtonsDown")
	await animation_player.animation_finished
	animation_player.play("SlideSaveStringUp")
	_on_save_string_edit_text_changed(save_string_edit.text)

func _on_load_confirm_pressed() -> void:
	_save_string = save_string_edit.text
	_fader_controller.fade_out()

func _on_save_string_edit_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		load_confirm.disabled = true
	else:
		load_confirm.disabled = false

func _on_back_pressed() -> void:
	animation_player.play_backwards("SlideSaveStringUp")
	await animation_player.animation_finished
	animation_player.play_backwards("SlideMainButtonsDown")

func _on_credits_pressed() -> void:
	animation_player.play("SlideMainButtonsDown")
	await animation_player.animation_finished
	animation_player.play("Credits")
	await animation_player.animation_finished
	animation_player.play_backwards("SlideMainButtonsDown")
