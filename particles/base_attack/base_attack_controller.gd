class_name BaseAttack
extends Node2D

@onready var die_timer: Timer = %DieTimer

func _ready() -> void:
	die_timer.timeout.connect(on_die_timer_timeout)
	on_start()

func on_start() -> void:
	pass

func on_die_timer_timeout() -> void:
	queue_free()
