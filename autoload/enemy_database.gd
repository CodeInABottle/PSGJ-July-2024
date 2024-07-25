extends Node

const ENEMY_DATA_PATH: String = "res://battle_resources/enemies/"
const ABILLITY_DATA_PATH: String = "res://battle_resources/abilities/"
const EARTH_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/EarthOrbStill.png")
const FIRE_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/FireOrbStill.png")
const WATER_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WaterOrbStill.png")
const WIND_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WindOrbStill.png")

# { enemy_name (String) : enemy_data (BattlefieldEnemyData) }
var _enemies: Dictionary = {}
# { ability_name (String) : ability_data (BattlefieldEnemyData) }
var _abilities: Dictionary = {}

func _ready() -> void:
	# Load Enemies
	var resource_files: PackedStringArray = DirAccess.get_files_at(ENEMY_DATA_PATH)
	for resource_file: String in resource_files:
		var data: BattlefieldEnemyData = load(ENEMY_DATA_PATH + resource_file)
		if data == null: continue
		if data["name"] in _enemies: continue

		_enemies[data["name"]] = data

	# Load abilities
	resource_files = DirAccess.get_files_at(ABILLITY_DATA_PATH)
	for resource_file: String in resource_files:
		var data: BattlefieldAbility = load(ABILLITY_DATA_PATH + resource_file)
		if data == null: continue
		var file_name: String = resource_file.split(".", false)[0]
		var ability_name: String = _pascal_string_split(file_name)

		if ability_name in _abilities: continue

		data.initialize(ability_name)
		_abilities[ability_name] = data

func get_enemy_data(enemy_name: String) -> BattlefieldEnemyData:
	assert(enemy_name in _enemies, "Enemy name: " + enemy_name + " does not exist/isn't loaded.")

	return _enemies[enemy_name]

func get_alchemy_data(enemy_name: String) -> Dictionary:
	var enemy_data: BattlefieldEnemyData = get_enemy_data(enemy_name)

	if enemy_data.resonate in TypeChart.PRIMARY_REAGENTS:
		return {
			"ap": 3,
			"regen": 1
		}
	elif enemy_data.resonate in TypeChart.COMPOUND_REAGENTS:
		return {
			"ap": 4,
			"regen": 2
		}
	elif enemy_data.resonate == TypeChart.ResonateType.CELESTIAL\
		or enemy_data.resonate == TypeChart.ResonateType.NITER:
		return {
			"ap": 5,
			"regen": 3
		}
	else:
		return {
			"ap": 7,
			"regen": 3
		}

func get_ability_data(ability_name: String) -> BattlefieldAbility:
	assert(ability_name in _abilities, "Ability name: " + ability_name + " does not exist/isn't loaded.")

	return _abilities[ability_name]

func get_ability_attack(ability_name: String) -> Dictionary:
	assert(ability_name in _abilities, "Ability name: " + ability_name + " does not exist/isn't loaded.")

	return {
		"attack": _abilities[ability_name]["attack"],
		"movement_speed": _abilities[ability_name]["attack_movement_speed"],
		"life_time": _abilities[ability_name]["attack_life_time"],
		"is_moving": _abilities[ability_name]["moving_attack"]
	}

func get_ability_recipe(ability_name: String) -> Array[TypeChart.ResonateType]:
	if ability_name not in _abilities: return []

	var data: Array[TypeChart.ResonateType] = []
	var reagent: TypeChart.ResonateType = (_abilities[ability_name] as BattlefieldAbility).reagent_a
	if reagent != TypeChart.ResonateType.NONE:
		data.push_back(reagent)
	reagent = (_abilities[ability_name] as BattlefieldAbility).reagent_b
	if reagent != TypeChart.ResonateType.NONE:
		data.push_back(reagent)
	reagent = (_abilities[ability_name] as BattlefieldAbility).reagent_c
	if reagent != TypeChart.ResonateType.NONE:
		data.push_back(reagent)
	reagent = (_abilities[ability_name] as BattlefieldAbility).reagent_d
	if reagent != TypeChart.ResonateType.NONE:
		data.push_back(reagent)

	return data

func get_ability_damage_data(ability_name: String) -> Dictionary:
	if ability_name not in _abilities: return {}

	var ability: BattlefieldAbility = _abilities[ability_name]
	return {
		"damage": ability.damage,
		"resonate_type": ability.resonate_type,
		"capture_rate": ability.capture_efficiency
	}

func get_ability_resonance(ability_name: String) -> TypeChart.ResonateType:
	if ability_name not in _abilities: return TypeChart.ResonateType.NONE

	return (_abilities[ability_name] as BattlefieldAbility).resonate_type

func get_ability_info(ability_name: String) -> Dictionary:
	if ability_name not in _abilities: return {}

	return  {
		"damage": _abilities[ability_name]["damage"],
		"description": _abilities[ability_name]["description"],
		"resonate": _abilities[ability_name]["resonate_type"],
		"efficiency": _abilities[ability_name]["capture_efficiency"],
		"cost": get_ability_recipe(ability_name)
	}

func get_ability_recipe_textures(ability_name: String) -> Array[Texture]:
	if ability_name not in _abilities: return []
	var component_data: Array[TypeChart.ResonateType] = get_ability_recipe(ability_name)
	var data: Array[Texture] = []
	for component: TypeChart.ResonateType in component_data:
		match component:
			TypeChart.ResonateType.AIR:
				data.push_back(WIND_ORB_STILL)
			TypeChart.ResonateType.EARTH:
				data.push_back(EARTH_ORB_STILL)
			TypeChart.ResonateType.FIRE:
				data.push_back(FIRE_ORB_STILL)
			TypeChart.ResonateType.WATER:
				data.push_back(WATER_ORB_STILL)
	return data

func get_abilities_from_shadow(shadow_name: String) -> Array[String]:
	if shadow_name not in _enemies: return []

	var abilities: Array[BattlefieldAbility] = (_enemies[shadow_name] as BattlefieldEnemyData).abilities
	var data: Array[String] = []
	for ability: BattlefieldAbility in abilities:
		data.push_back(ability.name)
	return data

func _pascal_string_split(string: String) -> String:
	var snake_case: String = string.to_snake_case()
	var words: Array[String] = []
	words.assign(snake_case.split("_", false))
	return " ".join(words.map(
		func(word: String) -> String:
			return word.capitalize()
	))
