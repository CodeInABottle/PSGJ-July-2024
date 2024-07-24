extends Node

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
