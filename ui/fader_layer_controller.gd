extends CanvasLayer

@export var fader_player: AnimationPlayer

signal fade_out_complete()
signal fade_in_complete()

func _ready() -> void:
	fader_player.animation_finished.connect(_on_animaiton_finished)

func _on_animaiton_finished(animation_name: String) -> void:
	match animation_name:
		"fade_out":
			on_fade_out()
		"fade_in":
			on_fade_in()
		_:
			pass

func on_fade_out() -> void:
	fade_out_complete.emit()

func on_fade_in() -> void:
	fade_in_complete.emit()

func fade_out() -> void:
	fader_player.play("fade_out")

func fade_in() -> void:
	fader_player.play("fade_in")
