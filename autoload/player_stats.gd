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

# { shadow_name (String) : [ (ability_names (String))... ] }
var _current_unlocked_shadows: Dictionary = {
	"Chicken": [	# TEMP: Hard coding "insertion" for now
		"Peck", "Smoke", "MudSlide"
	]
}
var _equipped_shadows: Array[String] = [
	"Chicken"	# TEMP: Waiting for inventory system; Hard coding "insertion" for now
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

func regen_alchemy_points() -> void:
	alchemy_points += LEVEL_DATA[level]["Regen"]

func get_max_alchemy_points() -> int:
	return LEVEL_DATA[level]["AP"]

func unlock_shadow(shadow_name: String, abilities: Array[String]) -> void:
	if shadow_name not in _current_unlocked_shadows:
		_current_unlocked_shadows[shadow_name] = []
	for ability: String in abilities:
		if ability in _current_unlocked_shadows[shadow_name]: continue
		_current_unlocked_shadows[shadow_name].push_back(ability)

func get_all_equipped_abilities() -> PackedStringArray:
	var data: PackedStringArray = []
	for shadow_name: String in _equipped_shadows:
		for ability_name: String in _current_unlocked_shadows[shadow_name]:
			if ability_name in data: continue
			data.push_back(ability_name)
	return data

func load_data(data: Dictionary) -> void:
	level = data.get("level", 0)
	health = data.get("health", MAX_HEALTH)
	_current_unlocked_shadows = data.get("unlocked_shadow_data", {})

func get_save_data() -> Dictionary:
	return {
		"level": level,
		"health": health,
		"unlocked_shadow_data": _current_unlocked_shadows
	}
