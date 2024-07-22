extends Node

signal health_updated
signal ap_updated

var player: Player

# If the player did no other actions when turn ends,
# gain this more AP on next turn.
const ADDITIONAL_AP_REGEN: int = 1
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
	"Tree": [	# TEMP: Hard coding "insertion" for now
		"Branch", "Hydrate"
	]
}
var _equipped_shadows: Array[String] = [
	"Tree"	# TEMP: Waiting for inventory system; Hard coding "insertion" for now
]

var max_health: int = 200:
	set(value):
		max_health = value

var level: int = 0:
	set(value):
		level = clampi(value, 0, 4)

var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_updated.emit()

var was_ap_used: bool = false
var alchemy_points: int:
	set(value):
		if value < alchemy_points:
			was_ap_used = true
		alchemy_points = clampi(value, 0, LEVEL_DATA[level]["AP"])
		ap_updated.emit()

func _ready() -> void:
	health = max_health
	level = 0
	alchemy_points = get_max_alchemy_points()

func reset_alchemy_points() -> void:
	alchemy_points = get_max_alchemy_points()
	was_ap_used = false

func regen_alchemy_points() -> void:
	alchemy_points += LEVEL_DATA[level]["Regen"]
	was_ap_used = false

func get_max_alchemy_points() -> int:
	return LEVEL_DATA[level]["AP"]

func unlock_shadow(shadow_name: String) -> void:
	var abilities: Array[String] = EnemyDatabase.get_abilities_from_shadow(shadow_name)
	if abilities.is_empty(): return

	if shadow_name not in _current_unlocked_shadows:
		_current_unlocked_shadows[shadow_name] = []

	for ability: String in abilities:
		if ability in _current_unlocked_shadows[shadow_name]: continue
		_current_unlocked_shadows[shadow_name].push_back(ability)

func get_all_unlocked_shadows() -> PackedStringArray:
	var data: PackedStringArray = []
	for shadow_name in _current_unlocked_shadows:
		data.push_back(shadow_name)
	return data

func get_all_equipped_abilities() -> PackedStringArray:
	var data: PackedStringArray = []
	for shadow_name: String in _equipped_shadows:
		for ability_name: String in _current_unlocked_shadows[shadow_name]:
			if ability_name in data: continue
			data.push_back(ability_name)
	return data

func load_data(data: Dictionary) -> void:
	level = data.get("level", 0)
	health = data.get("health", health)
	max_health = data.get("max_health", max_health)
	player.teleport_to(data.get("position", player.get_global_position()))
	_current_unlocked_shadows = data.get("unlocked_shadow_data", {})

func get_save_data() -> Dictionary:
	return {
		"level": level,
		"health": health,
		"max_health": max_health,
		"unlocked_shadow_data": _current_unlocked_shadows,
		"position": player.get_global_position()
	}
