extends Path2D

@onready var path_follow: PathFollow2D = %PathFollow

var runaway_pending: bool = false

func _ready() -> void:
	LevelManager.world_event_occurred.connect(on_world_event)
	LevelManager.world_enabled.connect(on_world_enabled)

func run_away() -> void:
	show()
	LevelManager.temp_statuses.append("just_caught_cat")
	var path_tween: Tween = create_tween()
	path_tween.finished.connect(on_path_finished)
	path_tween.tween_property(path_follow, "progress_ratio", 1.0, 5.0)

func on_world_event(event_name: String, args: Array) -> void:
	if event_name == "battle_finished":
		if args[0]["shadow_name"] == "Niter Tiger" and args[0]["captured"]:
			runaway_pending = true
			LevelManager.world_event_occurred.disconnect(on_world_event)

func on_path_finished() -> void:
	var path_tween: Tween = create_tween()
	path_tween.finished.connect(on_die_finished)
	path_tween.tween_property(self,"modulate",Color(1,1,1,0), 0.5)

func on_die_finished() -> void:
	queue_free()

func on_world_enabled() -> void:
	if runaway_pending:
		runaway_pending = false
		run_away.call_deferred()
