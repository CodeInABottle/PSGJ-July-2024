class_name GameArea
extends Node2D

@export var start_markers: Array[Marker2D]

var fader_controller: CanvasLayer

func _ready() -> void:
	LevelManager.level_loaded.emit(self)
	fader_controller = get_node("/root/Main/FaderLayer")
	fader_controller.fade_in()

func _process(_delta: float) -> void:
	pass

func start_at(entry_id: int) -> void:
	if start_markers.size() > entry_id:
		PlayerStats.player.teleport_to(start_markers[entry_id].get_global_position())
		SaveManager.attempt_load()
