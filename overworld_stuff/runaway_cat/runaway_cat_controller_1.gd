extends Path2D

@onready var path_follow: PathFollow2D = %PathFollow

func _ready() -> void:
	LevelManager.world_event_occurred.connect(on_world_event)

func run_away() -> void:
	show()
	var path_tween: Tween = create_tween()
	path_tween.tween_property(path_follow, "progress_ratio", 1.0, 5.0)
	path_tween.finished.connect(on_path_finished)

func on_world_event(event_name: String, args: Array) -> void:
	if event_name == "battle_finished":
		if args[0]["shadow_name"] == "Niter Tiger" and args[0]["captured"]:
			run_away()
			LevelManager.world_event_occurred.disconnect(on_world_event)

func on_path_finished() -> void:
	var path_tween: Tween = create_tween()
	path_tween.tween_property(self,"modulate",Color(1,1,1,0), 0.5)
	path_tween.finished.connect(on_die_finished)

func on_die_finished() -> void:
	LevelManager.temp_statuses.append("just_caught_cat")
	queue_free()
