@tool
class_name HTNNotificaionHandler
extends Control

const DEFAULT_COLOR := Color("e0e0e0")
const OK_COLOR := Color("65bcb2")
const WARNING_COLOR := Color("fedc65")
const ERROR_COLOR := Color("ff5f5f")

@onready var notice_label: Label = %NoticeLabel
@onready var timer: Timer = %Timer

func _exit_tree() -> void:
	clear()

func _ready() -> void:
	HTNGlobals.graph_altered.connect(clear)
	clear()

func clear() -> void:
	notice_label.text = ""
	notice_label.label_settings.font_color = DEFAULT_COLOR

func send_message(message: String, timer_length: float = 2.5) -> void:
	notice_label.text = message + " ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"
	notice_label.label_settings.font_color = OK_COLOR
	if timer_length > 0:
		timer.wait_time = timer_length
		timer.start()

func send_warning(message: String, timer_length: float = 5.0) -> void:
	notice_label.text = message
	notice_label.label_settings.font_color = WARNING_COLOR
	if timer_length > 0:
		timer.wait_time = timer_length
		timer.start()

func send_error(message: String, timer_length: float = 0.0) -> void:
	notice_label.text = message
	notice_label.label_settings.font_color = ERROR_COLOR
	if timer_length > 0:
		timer.wait_time = timer_length
		timer.start()

func _on_timer_timeout() -> void:
	clear()
