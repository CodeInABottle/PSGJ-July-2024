extends Node

signal health_updated
signal ap_updated

const MAX_HEALTH: int = 50
const LEVEL_DATA: Array[Dictionary] = [
	{
		"AP": 3,
		"Regen": 1
	},
	{
		"AP": 3,
		"Regen": 2
	},
	{
		"AP": 5,
		"Regen": 2
	},
	{
		"AP": 5,
		"Regen": 3
	},
	{
		"AP": 7,
		"Regen": 3
	},
]

var level: int = 0:
	set(value):
		level = clampi(value, 0, 4)

var health: int:
	set(value):
		health = clampi(value, 0, MAX_HEALTH)
		health_updated.emit()

var alchemy_points: int:
	set(value):
		alchemy_points = clampi(value, 0, LEVEL_DATA[level]["AP"])
		ap_updated.emit()

func _ready() -> void:
	health = MAX_HEALTH
	level = 0
	alchemy_points = get_max_alchemy_points()

func reset_alchemy_points() -> void:
	alchemy_points = get_max_alchemy_points()

func get_max_alchemy_points() -> int:
	return LEVEL_DATA[level]["AP"]

func load_data(data: Dictionary) -> void:
	level = data.get("level", 0)
	health = data.get("health", MAX_HEALTH)

func get_save_data() -> Dictionary:
	return {
		"level": level,
		"health": health,
	}
