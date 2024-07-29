extends Node

@onready var battlefield: BattlefieldManager = $"../.."
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var table_animation_player: AnimationPlayer = %TableAnimationPlayer
@onready var entity_tracker: BattlefieldEntityTracker = %EntityTracker
@onready var capture_animation_player: AnimationPlayer = %CaptureAnimationPlayer

func enter() -> void:
	table_animation_player.play("FadeOut")
	await table_animation_player.animation_finished
	entity_tracker.enemy_entity.play_capture_animation()
	await entity_tracker.enemy_entity.capture_animated
	capture_animation_player.play("Display")
	await capture_animation_player.animation_finished
	battlefield.captured_shadow()
	battlefield.won_battle()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
