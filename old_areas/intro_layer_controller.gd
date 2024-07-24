class_name IntroLayer
extends CanvasLayer

@onready var intro_timer: Timer = %IntroTimer
@onready var name_label: Label = %NameLabel
@onready var name_container: PanelContainer = %NameContainer

@export var fade_duration: float = 1.0
@export var stay_duration: float = 3.0

func _ready() -> void:
	intro_timer.timeout.connect(_on_intro_timer_timeout)

func _on_intro_timer_timeout() -> void:
	var name_tween: Tween = name_container.create_tween()
	name_tween.tween_property(name_container, "modulate", Color(1,1,1,0), fade_duration)

func trigger() -> void:
	name_label.text = LevelManager.region_name
	
	var name_tween: Tween = name_container.create_tween()
	name_tween.tween_property(name_container, "modulate", Color(1,1,1,1), fade_duration)
	intro_timer.start(stay_duration)
