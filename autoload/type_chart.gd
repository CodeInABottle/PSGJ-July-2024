extends Node

const EARTH_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/EarthOrbStill.png")
const FIRE_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/FireOrbStill.png")
const WATER_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WaterOrbStill.png")
const WIND_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WindOrbStill.png")

enum ResonateType {
	NONE = 0,
	EARTH = 0b1000,
	WATER = 0b0100,
	AIR = 0b0010,
	FIRE = 0b0001,
	SALT = 0b1100,	# Earth + Water
	MERCURY = 0b0110,	# Water + Air
	SULPHUR = 0b0011,	# Air + Fire
	CELESTIAL = 0b1110,	# Earth + Water + Air
	NITER = 0b0111,	# Water + Air + Fire
	METAL = 0b1111	# All
}

enum CostType { REDUCE, INCREASE, SET }

const TEXTURE_LOOK_UP_TABLE: Dictionary = {
	TypeChart.ResonateType.EARTH: 6,
	TypeChart.ResonateType.WATER: 7,
	TypeChart.ResonateType.AIR: 4,
	TypeChart.ResonateType.FIRE: 5,
	TypeChart.ResonateType.SALT: 3,
	TypeChart.ResonateType.MERCURY: 9,
	TypeChart.ResonateType.SULPHUR: 8,
	TypeChart.ResonateType.CELESTIAL: 2,
	TypeChart.ResonateType.NITER: 1,
	TypeChart.ResonateType.METAL: 0,
}
const TEXTURE_TABLE: Dictionary = {
	TypeChart.ResonateType.EARTH: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0007.png"),
	TypeChart.ResonateType.WATER: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0008.png"),
	TypeChart.ResonateType.AIR: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0005.png"),
	TypeChart.ResonateType.FIRE: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0006.png"),
	TypeChart.ResonateType.SALT: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0004.png"),
	TypeChart.ResonateType.MERCURY: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0010.png"),
	TypeChart.ResonateType.SULPHUR: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0009.png"),
	TypeChart.ResonateType.CELESTIAL: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0003.png"),
	TypeChart.ResonateType.NITER: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0002.png"),
	TypeChart.ResonateType.METAL: preload("res://assets/sprites/shadow_alchemybench/Symbols/Symbols_0001.png")
}
const MAX_EFFECT_STACK: int = 3
const PRIMARY_REAGENTS: Array[ResonateType]\
	= [ResonateType.EARTH, ResonateType.WATER, ResonateType.AIR, ResonateType.FIRE]
const COMPOUND_REAGENTS: Array[ResonateType]\
	= [ResonateType.SALT, ResonateType.MERCURY, ResonateType.SULPHUR]

func get_resonance_breakdown(resonance: ResonateType) -> Array[ResonateType]:
	match resonance:
		ResonateType.EARTH, ResonateType.WATER, ResonateType.AIR, ResonateType.FIRE:
			return [resonance]
		ResonateType.SALT:
			return [ResonateType.EARTH, ResonateType.WATER]
		ResonateType.MERCURY:
			return [ResonateType.WATER, ResonateType.AIR]
		ResonateType.SULPHUR:
			return [ResonateType.AIR, ResonateType.FIRE]
		ResonateType.CELESTIAL:
			return [ResonateType.EARTH, ResonateType.WATER, ResonateType.AIR]
		ResonateType.NITER:
			return [ResonateType.WATER, ResonateType.AIR, ResonateType.FIRE]
		ResonateType.METAL:
			return PRIMARY_REAGENTS
		_: return []

func get_texture(resonance: ResonateType) -> Texture:
	if resonance not in PRIMARY_REAGENTS: return null

	match resonance:
		TypeChart.ResonateType.EARTH:
			return EARTH_ORB_STILL
		TypeChart.ResonateType.WATER:
			return WATER_ORB_STILL
		TypeChart.ResonateType.AIR:
			return WIND_ORB_STILL
		TypeChart.ResonateType.FIRE:
			return FIRE_ORB_STILL
	return null

func get_symbol_texture(resonance: ResonateType) -> Texture:
	if resonance not in TEXTURE_TABLE: return null

	return TEXTURE_TABLE[resonance]
