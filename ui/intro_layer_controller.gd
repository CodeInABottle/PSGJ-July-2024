class_name IntroLayer
extends CanvasLayer

@onready var intro_timer: Timer = %IntroTimer
@onready var name_label: Label = %NameLabel
@onready var map: Control = %Map

@export var fade_duration: float = 1.0
@export var total_duration: float = 3.0

var _tween: Tween

func _ready() -> void:
	map.modulate = Color(1, 1, 1, 0)
	intro_timer.timeout.connect(_on_intro_timer_timeout)
	LevelManager.world_event_occurred.connect(on_world_event)
	DialogueManager.dialogue_started.connect(on_dialogue_started)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward") or event.is_action_pressed("backward")\
			or event.is_action_pressed("left") or event.is_action_pressed("right"):
		if _tween: _tween.kill()
		_tween = map.create_tween()
		_tween.tween_property(map, "modulate", Color(1,1,1,0), 0.25)

func _on_intro_timer_timeout() -> void:
	if _tween:
		_tween.kill()
	_tween = map.create_tween()
	_tween.tween_property(map, "modulate", Color(1,1,1,0), fade_duration)

func trigger() -> void:
	name_label.text = LevelManager.region_name

	if _tween:
		_tween.kill()
	_tween = map.create_tween()
	_tween.tween_property(map, "modulate", Color(1,1,1,1), fade_duration)
	intro_timer.start(total_duration)

func on_world_event(event_name: String, _args:Array) -> void:
	if event_name.begins_with("item_get:"):
		queue_free()

func on_dialogue_started() -> void:
	queue_free()
