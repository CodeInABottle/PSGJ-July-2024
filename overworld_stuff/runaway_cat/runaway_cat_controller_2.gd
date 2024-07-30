extends Path2D

@onready var path_follow = %PathFollow
@onready var cat_sprite = %RunawayCat

const FLIP_THRESHOLD: float = 0.536

func _ready() -> void:
	if LevelManager.temp_statuses.has("just_caught_cat"):
		LevelManager.temp_statuses.erase("just_caught_cat")
		run_away()

func _process(_delta: float) -> void:
	if path_follow.progress_ratio >= FLIP_THRESHOLD:
		cat_sprite.flip_h = true

func run_away() -> void:
	show()
	var path_tween: Tween = create_tween()
	path_tween.tween_property(path_follow, "progress_ratio", 1.0, 30.0)
	path_tween.finished.connect(on_path_finished)

func on_path_finished() -> void:
	var path_tween: Tween = create_tween()
	path_tween.tween_property(self,"modulate",Color(1,1,1,0), 0.5)
	path_tween.finished.connect(on_die_finished)

func on_die_finished() -> void:
	LevelManager.temp_statuses.append("cat_left_remembrance")
	queue_free()
