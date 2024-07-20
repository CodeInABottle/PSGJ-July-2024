extends Node

const ENEMY_DATA_PATH: String = "res://battle_resources/enemies/"
const ABILLITY_DATA_PATH: String = "res://battle_resources/abilities/"

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

		if file_name in _abilities: continue

		data.initialize(file_name)
		_abilities[file_name] = data

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

func get_ability_recipe(ability_name: String) -> Array[TypeChart.ResonateType]:
	if ability_name not in _abilities: return []

	var data: Array[TypeChart.ResonateType] = []
	var reagent: TypeChart.ResonateType = (_abilities[ability_name] as BattlefieldAbility).reagent_a
	if reagent != TypeChart.ResonateType.NONE:
		data.push_back(reagent)
	reagent = (_abilities[ability_name] as BattlefieldAbility).reagent_b
	if reagent != TypeChart.ResonateType.NONE:
		data.push_back(reagent)

	return data

func get_ability_damage_data(ability_name: String) -> Dictionary:
	if ability_name not in _abilities: return {}

	var ability: BattlefieldAbility = _abilities[ability_name]
	return {
		"damage": ability.damage,
		"resonate_type": ability.resonate_type,
		"capture_rate": ability.capture_efficiency,
	}

func get_ability_mods(ability_name: String) -> Array[BattlefieldAttackModifier]:
	if ability_name not in _abilities: return []

	return (_abilities[ability_name] as BattlefieldAbility).modifiers
