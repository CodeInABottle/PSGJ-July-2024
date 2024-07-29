extends Node

@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var enemy_turn_skip: Control = %EnemyTurnSkip
@onready var player_skip_turn: Control = %PlayerSkipTurn
@onready var table_animation_player: AnimationPlayer = %TableAnimationPlayer

func enter() -> void:
	table_animation_player.play("FadeOut")
	await table_animation_player.animation_finished

	if entity_tracker.is_players_turn:
		player_skip_turn.play()
	else:
		enemy_turn_skip.play()

func exit() -> void:
	table_animation_player.play_backwards("FadeOut")
	await table_animation_player.animation_finished

func update(_delta: float) -> void:
	pass

func _on_player_skip_turn_finished() -> void:
	entity_tracker.end_turn()

func _on_enemy_turn_skip_finished() -> void:
	entity_tracker.end_turn()
