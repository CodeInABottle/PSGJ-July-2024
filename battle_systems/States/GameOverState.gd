extends Node

@onready var battlefield: BattlefieldManager = $"../.."
@onready var game_over_player: AnimationPlayer = %GameOverPlayer
@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker

func enter() -> void:
	entity_tracker.battle_over = true
	game_over_player.play("FadeIn")

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func _on_respawn_button_pressed() -> void:
	battlefield.lost_battle()
