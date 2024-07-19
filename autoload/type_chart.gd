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

enum Effect {
	NONE = 0,
	HEAL = 1,
	BURNING = 2,	# Fire
	DROWNING = 3,	# Water
	SUFFICATION = 4,# Air
	DAZE = 5,		# Earth
}

const MAX_EFFECT_STACK: int = 3
const PRIMARY_REAGENTS: Array[ResonateType]\
	= [ResonateType.EARTH, ResonateType.WATER, ResonateType.AIR, ResonateType.FIRE]
const COMPOUND_REAGENTS: Array[ResonateType]\
	= [ResonateType.SALT, ResonateType.MERCURY, ResonateType.SULPHUR]

func is_effective_against(current_types: Array[ResonateType], opponent_type: ResonateType) -> bool:
	# Only a single element -- Primary reagents only
	if current_types.size() == 1:
		assert(
			current_types[0] in PRIMARY_REAGENTS,
			"Every Ability either uses up to 2 reagents that consist of primary reagents."
		)
		# check effectiveness horizontally
		if _parse_ability_tier(opponent_type) == 1:
			if current_types[0] == opponent_type:
				return true
		# Need more than one reagent to combat the heigher tiers
		return false

	# Combine all bits
	var flags: int = 0
	for type: ResonateType in current_types:
		flags |= type

	# Compare each bit to see if it matches
	for i: int in 4:
		var opponent_bit: int = opponent_type & (1 << i)
		var flags_bit: int = flags & (1 << i)
		if opponent_bit != flags_bit:
			# Current has that bit set, but opponent doesn't - thats fine
			if flags_bit > opponent_bit:
				continue
			# Mismatching bits - Opponent's bit set, but current isn't
			return false

	return true

func _parse_ability_tier(reagent: ResonateType) -> int:
	if reagent in PRIMARY_REAGENTS: return 1
	if reagent in COMPOUND_REAGENTS: return 2
	if reagent == ResonateType.CELESTIAL or reagent == ResonateType.NITER: return 3
	return 4
