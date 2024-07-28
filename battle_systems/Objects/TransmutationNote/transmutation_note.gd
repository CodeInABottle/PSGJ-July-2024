extends Area2D

@export var drop_location: BattlefieldReagentDropLocation
@export var transmutation_page: Control

@onready var timer: Timer = %Timer

func _ready() -> void:
	transmutation_page.hide()

func _on_mouse_entered() -> void:
	if drop_location.is_holding_something() or transmutation_page.visible: return
	timer.start()

func _on_mouse_exited() -> void:
	timer.stop()
	transmutation_page.hide()

func _on_timer_timeout() -> void:
	transmutation_page.show()
