class_name Petter
extends InteractableHost

signal pet_started()
signal pet_stopped() 

var player_sprite: AnimatedSprite2D

var _is_ending: bool = false
var _is_starting: bool = false
@onready var start_position: Vector2 = get_position()

func _ready() -> void:
	interactable.interaction_started.connect(on_interaction_started)
	interactable.interaction_advanced.connect(on_interaction_advanced)
	interactable.interaction_quick_closed.connect(on_interaction_quick_closed)

func on_interaction_started(_interactable: Interactable) -> void:
	if not _is_ending and not _is_starting:
		player_sprite = PlayerStats.player.player_visual_body.player_sprite
		soft_disco_signals()
		PlayerStats.player.redirect(global_position, 2.0)
		_is_starting = true
		PlayerStats.player.redirect_complete.connect(on_target_reached)
		pet_started.emit()

func on_interaction_advanced(_interactable: Interactable) -> void:
	end_interaction()

func end_interaction() -> void:
	if not _is_ending and not _is_starting:
		_is_ending = true
		player_sprite.pause()
		player_sprite.animation_finished.connect(on_stop_pet_finished)
		player_sprite.play("stop_pet_dog")

func on_interaction_quick_closed() -> void:
	_on_interaction_ended()

func soft_disco_signals() -> void:
	if PlayerStats.player.nav.target_reached.is_connected(on_target_reached):
		PlayerStats.player.nav.target_reached.disconnect(on_target_reached)
	
	if player_sprite.animation_finished.is_connected(on_start_pet_finished):
		player_sprite.animation_finished.disconnect(on_start_pet_finished)
	
	if player_sprite.animation_finished.is_connected(on_start_pet_finished):
		player_sprite.animation_finished.disconnect(on_start_pet_finished)

func _on_interaction_ended() -> void:
	soft_disco_signals()
	
	_is_ending = false
	_is_starting = false
	pet_stopped.emit()
	player_sprite.set_animation("walk")
	player_sprite.set_frame(0)

func on_target_reached() -> void:
	PlayerStats.player.redirect_complete.disconnect(on_target_reached)
	player_sprite.animation_finished.connect(on_start_pet_finished)
	player_sprite.play("start_pet_dog")
	if PlayerStats.player.get_global_position().x < get_parent().global_position.x:
		player_sprite.flip_h = true
		get_parent().flip_h = false
		position.x = start_position.x
	else:
		player_sprite.flip_h = false
		get_parent().flip_h = true
		position.x = -start_position.x

func on_start_pet_finished() -> void:
	_is_starting = false
	player_sprite.animation_finished.disconnect(on_start_pet_finished)
	player_sprite.play("pet_dog")

func on_stop_pet_finished() -> void:
	player_sprite.animation_finished.disconnect(on_stop_pet_finished)
	_on_interaction_ended()
	interactable.end_interaction()
	PlayerStats.player.hint_manager.play_quip("good_boy")

func is_valid() -> bool:
	PlayerStats.player.nav.set_target_position(global_position)
	await get_tree().physics_frame
	if PlayerStats.player.nav.is_target_reachable():
		return true
	
	return false
