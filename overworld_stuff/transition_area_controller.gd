class_name TransitionArea
extends Area2D

@export var transition_scene_name: String = ""
@export var transition_entry_id: int = 0

var fader_controller: CanvasLayer
var _is_entering: bool = false

func _ready() -> void:
	LevelManager.is_transitioning = false
	body_entered.connect(_on_player_entered)

func _on_player_entered(entered_body: Node2D) -> void:
	if entered_body.is_in_group("player") and not _is_entering:
		_is_entering = true
		fader_controller = get_node("/root/Main/FaderLayer")
		fader_controller.fade_out_complete.connect(on_fade_out_complete)
		fader_controller.fade_out()

func on_fade_out_complete() -> void:
	DialogueManager.end_dialogue()
	LevelManager.is_transitioning = true
	fader_controller.fade_out_complete.disconnect(on_fade_out_complete)
	LevelManager.load_world(transition_scene_name, transition_entry_id)
