class_name Shiny
extends Sprite2D

@export var shiny_radius: float = 150.0

@export var pickup_area: Area2D
@export var shiny_area: Area2D
@export var shiny_sprite: Sprite2D
@export var shiny_player: AnimationPlayer 
@export var fade_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shiny_area.body_entered.connect(on_body_entered_area)
	shiny_area.body_exited.connect(on_body_exited_area)
	fade_timer.timeout.connect(on_fade_timer_timeout)
	pickup_area.get_child(0).shape.radius = shiny_radius

func on_body_entered_area(entered_body: Node2D) -> void:
	if entered_body.is_in_group("player"):
		shiny_player.play("bounce")
		var shiny_tween: Tween = shiny_sprite.create_tween()
		shiny_tween.tween_property(shiny_sprite, "modulate", Color(1,1,1,1), 0.5)

func on_body_exited_area(exited_body: Node2D) -> void:
	if exited_body.is_in_group("player"):
		stop_shiny.call_deferred()

func on_fade_timer_timeout() -> void:
	shiny_player.stop()

func stop_shiny() -> void:
	var shiny_tween: Tween = shiny_sprite.create_tween()
	shiny_tween.tween_property(shiny_sprite, "modulate", Color(1,1,1,0), 0.5)
	fade_timer.start()

func show_shiny() -> void:
	shiny_player.play()
	var shiny_tween: Tween = shiny_sprite.create_tween()
	shiny_tween.tween_property(shiny_sprite, "modulate", Color(1,1,1,1), 0.5)
