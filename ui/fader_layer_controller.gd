extends CanvasLayer

@export var fader_player: AnimationPlayer

signal fade_out_complete()
signal fade_in_complete()
signal fade_to_translucent_complete()
signal fade_from_translucent_compelte()

func _ready() -> void:
	fader_player.animation_finished.connect(_on_animaiton_finished)

func _on_animaiton_finished(animation_name: String) -> void:
	match animation_name:
		"fade_out":
			fade_out_complete.emit()
		"fade_in":
			fade_in_complete.emit()
		"fade_to_translucent":
			fade_to_translucent_complete.emit()
		"fade_from_translucent":
			fade_from_translucent_compelte.emit()
		_:
			pass

func fade_out() -> void:
	fader_player.play("fade_out")

func fade_in() -> void:
	fader_player.play("fade_in")

func fade_to_translucent() -> void:
	fader_player.play("fade_to_translucent")

func fade_from_translucent() -> void:
	fader_player.play("fade_from_translucent")
