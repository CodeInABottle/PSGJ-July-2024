class_name GameArea
extends Node

@onready var warp_points: Node = %WarpPoints
@onready var setup_timer: Timer = %SetupTimer

var fader_controller: CanvasLayer
var _warp_points: Array[Marker2D] = []

func _ready() -> void:
	# Do what we need
	for warp_point: Marker2D in warp_points.get_children():
		_warp_points.push_back(warp_point)
	setup_timer.timeout.connect(_on_setup_timeout)
	setup_timer.start()

	# Alert the level manager we done setting up
	LevelManager.level_loaded.emit(self)

func start_at(entry_id: int) -> void:
	# Check if valid entry ID
	if entry_id < 0 or entry_id > _warp_points.size(): return

	# Warp and load
	PlayerStats.player.teleport_to(_warp_points[entry_id].get_global_position())
	SaveManager.attempt_load()

func _on_setup_timeout() -> void:
	MenuManager.fader_controller.fade_in()
