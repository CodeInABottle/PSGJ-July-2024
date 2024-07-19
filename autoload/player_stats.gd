extends Node

signal health_updated
signal ap_updated

var player: Player

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

# { shadow_name (String) : [ (ability_names (String))... ] }
var _current_unlocked_shadows: Dictionary = {}

var max_health: int = 50:
	set(value):
		max_health = value

var level: int = 0:
	set(value):
		level = clampi(value, 0, 4)

var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_updated.emit()

var alchemy_points: int:
	set(value):
		alchemy_points = clampi(value, 0, LEVEL_DATA[level]["AP"])
		ap_updated.emit()

func _ready() -> void:
	health = max_health
	level = 0
	alchemy_points = get_max_alchemy_points()

func reset_alchemy_points() -> void:
	alchemy_points = get_max_alchemy_points()

func get_max_alchemy_points() -> int:
	return LEVEL_DATA[level]["AP"]

func unlock_shadow(shadow_name: String, abilities: Array[String]) -> void:
	if shadow_name not in _current_unlocked_shadows:
		_current_unlocked_shadows[shadow_name] = []
	for ability: String in abilities:
		if ability in _current_unlocked_shadows[shadow_name]: continue
		_current_unlocked_shadows[shadow_name].push_back(ability)

func load_data(data: Dictionary) -> void:
	level = data.get("level", 0)
	health = data.get("health", health)
	max_health = data.get("max_health", max_health)
	player.set_global_position(data.get("position", player.get_global_position()))
	_current_unlocked_shadows = data.get("unlocked_shadow_data", {})

func get_save_data() -> Dictionary:
	return {
		"level": level,
		"health": health,
		"max_health": max_health,
		"unlocked_shadow_data": _current_unlocked_shadows,
		"position": player.get_global_position()
	}
