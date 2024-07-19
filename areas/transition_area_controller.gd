class_name TransitionArea
extends Area2D

@export var transition_scene_name: String = ""
@export var transition_entry_id: int = 0

func _ready() -> void:
	body_entered.connect(_on_player_entered)

func _on_player_entered(entered_body: Node2D) -> void:
	if entered_body.is_in_group("player"):
		LevelManager.load_world(transition_scene_name, transition_entry_id)
