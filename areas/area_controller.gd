class_name AreaController
extends Node2D

@export var start_markers: Array[Marker2D]

func _ready():
	LevelManager.level_loaded.emit(self)

func _process(delta):
	pass

func start_at(entry_id: int) -> void:
	if start_markers.size() > entry_id:
		PlayerStats.player.teleport_to(start_markers[entry_id].get_global_position())
		SaveManager.attempt_load()
