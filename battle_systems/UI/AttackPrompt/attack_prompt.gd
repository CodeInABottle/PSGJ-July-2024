class_name AttackPrompt
extends Control

const ANIMATION_TIME: float = 0.3

signal finished

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var user_label: Label = %UserLabel
@onready var attack_label: Label = %AttackLabel
@onready var timer: Timer = %Timer

func _ready() -> void:
	animation_player.play("RESET")
	timer.wait_time += ANIMATION_TIME

func set_data(user: String, ability_name: String) -> void:
	user_label.text = user
	attack_label.text = ability_name
	animation_player.play("SlideIn")
	timer.start()

func _on_timer_timeout() -> void:
	animation_player.play_backwards("SlideIn")
	finished.emit()
