extends Node

const ENEMY_DATA_PATH: String = "res://battle_resources/enemies/"
const ABILLITY_DATA_PATH: String = "res://battle_resources/abilities/"
const EARTH_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/EarthOrbStill.png")
const FIRE_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/FireOrbStill.png")
const WATER_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WaterOrbStill.png")
const WIND_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WindOrbStill.png")
const SHADOW_COLOR: Dictionary = {
	TypeChart.ResonateType.EARTH: Color("8f563b"),
	TypeChart.ResonateType.WATER: Color("5fcde4"),
	TypeChart.ResonateType.AIR: Color("9badb7"),
	TypeChart.ResonateType.FIRE: Color("df7126"),
	TypeChart.ResonateType.SALT: Color("847e87"),
	TypeChart.ResonateType.MERCURY: Color("ac3232"),
	TypeChart.ResonateType.SULPHUR: Color("fbf236"),
	TypeChart.ResonateType.CELESTIAL: Color("76428a"),
	TypeChart.ResonateType.NITER: Color("323c39"),
	TypeChart.ResonateType.METAL: Color("696a6a"),
}
const CAPTURE_RATE_EFFICENCY: float = 1.25

enum SpecialFrameState { NONE, ON_HURT, ON_ATTACK, LAST_30_PRECENT }

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

func get_shadow_color(shadow_name: String) -> Color:
	assert(shadow_name in _enemies, "Enemy name: " + shadow_name + " does not exist/isn't loaded.")

	var resonance: TypeChart.ResonateType = (_enemies[shadow_name] as BattlefieldEnemyData).resonate
	return SHADOW_COLOR[resonance]

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

	return (_abilities[ability_name] as BattlefieldAbility).get_components()

func get_ability_damage(ability_name: String) -> int:
	if ability_name not in _abilities: return 0

	var ability: BattlefieldAbility = _abilities[ability_name]
	var damage: int = ability.damage
	if ability.precentage_damage > 0:
		damage = floori(float(PlayerStats.max_health) * (float(ability.precentage_damage) / 100.0))
	return damage

func get_ability_damage_data(ability_name: String) -> Dictionary:
	if ability_name not in _abilities: return {}

	var ability: BattlefieldAbility = _abilities[ability_name]
	var damage: int = ability.damage
	if ability.precentage_damage > 0:
		damage = floori(float(PlayerStats.max_health) * (float(ability.precentage_damage) / 100.0))
	return {
		"damage": damage,
		"resonate_type": ability.resonate_type,
		"components": ability.get_components()
	}

func get_ability_resonance(ability_name: String) -> TypeChart.ResonateType:
	if ability_name not in _abilities: return TypeChart.ResonateType.NONE

	return (_abilities[ability_name] as BattlefieldAbility).resonate_type

func get_ability_info(ability_name: String) -> Dictionary:
	if ability_name not in _abilities: return {}

	return  {
		"damage": get_ability_damage(ability_name),
		"description": _abilities[ability_name]["description"],
		"resonate": _abilities[ability_name]["resonate_type"],
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
