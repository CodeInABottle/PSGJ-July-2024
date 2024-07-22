class_name GameArea
extends Node2D

@export var start_markers: Array[Marker2D]
@export var setup_timer: Timer

var fader_controller: CanvasLayer

func _ready() -> void:
	LevelManager.level_loaded.emit(self)
	setup_timer.timeout.connect(on_setup_timeout)
	setup_timer.start()

func _process(_delta: float) -> void:
	pass

func start_at(entry_id: int) -> void:
	if start_markers.size() > entry_id:
		PlayerStats.player.teleport_to(start_markers[entry_id].get_global_position())
		SaveManager.attempt_load()

func on_setup_timeout() -> void:
	MenuManager.fader_controller.fade_in()
