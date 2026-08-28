class_name PrimaryStatsState
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal primary_stats_changed(
	snapshot: Dictionary
)


# =========================================================
# IDENTIDAD / PROGRESIÓN
# =========================================================

var revision: int = 0

var level: int = 1

var reset_count: int = 0


# =========================================================
# BASE
# =========================================================

var base_strength: int = 0

var base_agility: int = 0

var base_vitality: int = 0

var base_energy: int = 0


# =========================================================
# ALLOCATED
# =========================================================

var allocated_strength: int = 0

var allocated_agility: int = 0

var allocated_vitality: int = 0

var allocated_energy: int = 0


# =========================================================
# PERMANENT
# =========================================================

var permanent_strength: int = 0

var permanent_agility: int = 0

var permanent_vitality: int = 0

var permanent_energy: int = 0


# =========================================================
# BUDGET
# =========================================================

var stat_points_per_level: int = 0

var stat_points_per_reset: int = 0

var level_points: int = 0

var reset_points: int = 0

var bonus_stat_points: int = 0

var total_points: int = 0

var spent_points: int = 0

var unspent_points: int = 0


# =========================================================
# APLICAR SNAPSHOT AUTORITATIVO
# =========================================================

func apply_snapshot(
	snapshot: Dictionary
) -> bool:
	var progression_value: Variant = (
		snapshot.get(
			"progression",
			null
		)
	)


	if typeof(progression_value) != TYPE_DICTIONARY:
		return false


	var base_value: Variant = (
		snapshot.get(
			"base",
			null
		)
	)


	if typeof(base_value) != TYPE_DICTIONARY:
		return false


	var allocated_value: Variant = (
		snapshot.get(
			"allocated",
			null
		)
	)


	if typeof(allocated_value) != TYPE_DICTIONARY:
		return false


	var permanent_value: Variant = (
		snapshot.get(
			"permanent",
			null
		)
	)


	if typeof(permanent_value) != TYPE_DICTIONARY:
		return false


	var budget_value: Variant = (
		snapshot.get(
			"budget",
			null
		)
	)


	if typeof(budget_value) != TYPE_DICTIONARY:
		return false


	var progression: Dictionary = (
		progression_value
	)

	var base: Dictionary = (
		base_value
	)

	var allocated: Dictionary = (
		allocated_value
	)

	var permanent: Dictionary = (
		permanent_value
	)

	var budget: Dictionary = (
		budget_value
	)


	var next_revision := int(
		snapshot.get(
			"revision",
			-1
		)
	)

	var next_level := int(
		progression.get(
			"level",
			0
		)
	)

	var next_reset_count := int(
		progression.get(
			"reset_count",
			-1
		)
	)


	var next_base_strength := int(
		base.get(
			"strength",
			-1
		)
	)

	var next_base_agility := int(
		base.get(
			"agility",
			-1
		)
	)

	var next_base_vitality := int(
		base.get(
			"vitality",
			-1
		)
	)

	var next_base_energy := int(
		base.get(
			"energy",
			-1
		)
	)


	var next_allocated_strength := int(
		allocated.get(
			"strength",
			-1
		)
	)

	var next_allocated_agility := int(
		allocated.get(
			"agility",
			-1
		)
	)

	var next_allocated_vitality := int(
		allocated.get(
			"vitality",
			-1
		)
	)

	var next_allocated_energy := int(
		allocated.get(
			"energy",
			-1
		)
	)


	var next_permanent_strength := int(
		permanent.get(
			"strength",
			-1
		)
	)

	var next_permanent_agility := int(
		permanent.get(
			"agility",
			-1
		)
	)

	var next_permanent_vitality := int(
		permanent.get(
			"vitality",
			-1
		)
	)

	var next_permanent_energy := int(
		permanent.get(
			"energy",
			-1
		)
	)


	var next_bonus_stat_points := int(
		snapshot.get(
			"bonus_stat_points",
			-1
		)
	)


	var next_points_per_level := int(
		budget.get(
			"points_per_level",
			-1
		)
	)

	var next_points_per_reset := int(
		budget.get(
			"points_per_reset",
			-1
		)
	)

	var next_level_points := int(
		budget.get(
			"level_points",
			-1
		)
	)

	var next_reset_points := int(
		budget.get(
			"reset_points",
			-1
		)
	)

	var next_bonus_points := int(
		budget.get(
			"bonus_points",
			-1
		)
	)

	var next_total_points := int(
		budget.get(
			"total_points",
			-1
		)
	)

	var next_spent_points := int(
		budget.get(
			"spent_points",
			-1
		)
	)

	var next_unspent_points := int(
		budget.get(
			"unspent_points",
			-1
		)
	)


	# =====================================================
	# VALIDACIÓN
	# =====================================================

	if next_revision < 0:
		return false


	if next_level < 1:
		return false


	if next_reset_count < 0:
		return false


	if (
		next_base_strength < 0
		or
		next_base_agility < 0
		or
		next_base_vitality < 0
		or
		next_base_energy < 0
	):
		return false


	if (
		next_allocated_strength < 0
		or
		next_allocated_agility < 0
		or
		next_allocated_vitality < 0
		or
		next_allocated_energy < 0
	):
		return false


	if (
		next_permanent_strength
		!=
		next_base_strength
		+
		next_allocated_strength
	):
		return false


	if (
		next_permanent_agility
		!=
		next_base_agility
		+
		next_allocated_agility
	):
		return false


	if (
		next_permanent_vitality
		!=
		next_base_vitality
		+
		next_allocated_vitality
	):
		return false


	if (
		next_permanent_energy
		!=
		next_base_energy
		+
		next_allocated_energy
	):
		return false


	if next_points_per_level <= 0:
		return false


	if next_points_per_reset <= 0:
		return false


	if (
		next_level_points
		!=
		(
			(next_level - 1)
			*
			next_points_per_level
		)
	):
		return false


	if (
		next_reset_points
		!=
		(
			next_reset_count
			*
			next_points_per_reset
		)
	):
		return false


	if next_bonus_stat_points < 0:
		return false


	if (
		next_bonus_points
		!=
		next_bonus_stat_points
	):
		return false


	var expected_spent_points := (
		next_allocated_strength
		+
		next_allocated_agility
		+
		next_allocated_vitality
		+
		next_allocated_energy
	)


	if (
		next_spent_points
		!=
		expected_spent_points
	):
		return false


	var expected_total_points := (
		next_level_points
		+
		next_reset_points
		+
		next_bonus_stat_points
	)


	if (
		next_total_points
		!=
		expected_total_points
	):
		return false


	if next_spent_points > next_total_points:
		return false


	if (
		next_unspent_points
		!=
		next_total_points
		-
		next_spent_points
	):
		return false


	if next_revision == 0:
		if next_spent_points != 0:
			return false


		if next_bonus_stat_points != 0:
			return false


	# =====================================================
	# APLICAR
	# =====================================================

	revision = next_revision

	level = next_level

	reset_count = next_reset_count


	base_strength = next_base_strength

	base_agility = next_base_agility

	base_vitality = next_base_vitality

	base_energy = next_base_energy


	allocated_strength = (
		next_allocated_strength
	)

	allocated_agility = (
		next_allocated_agility
	)

	allocated_vitality = (
		next_allocated_vitality
	)

	allocated_energy = (
		next_allocated_energy
	)


	permanent_strength = (
		next_permanent_strength
	)

	permanent_agility = (
		next_permanent_agility
	)

	permanent_vitality = (
		next_permanent_vitality
	)

	permanent_energy = (
		next_permanent_energy
	)


	stat_points_per_level = (
		next_points_per_level
	)

	stat_points_per_reset = (
		next_points_per_reset
	)

	level_points = next_level_points

	reset_points = next_reset_points

	bonus_stat_points = (
		next_bonus_stat_points
	)

	total_points = next_total_points

	spent_points = next_spent_points

	unspent_points = next_unspent_points


	primary_stats_changed.emit(
		to_snapshot()
	)


	return true


# =========================================================
# SNAPSHOT
# =========================================================

func to_snapshot() -> Dictionary:
	return {
		"revision": revision,

		"progression": {
			"level": level,
			"reset_count": reset_count,
		},

		"base": {
			"strength": base_strength,
			"agility": base_agility,
			"vitality": base_vitality,
			"energy": base_energy,
		},

		"allocated": {
			"strength": allocated_strength,
			"agility": allocated_agility,
			"vitality": allocated_vitality,
			"energy": allocated_energy,
		},

		"permanent": {
			"strength": permanent_strength,
			"agility": permanent_agility,
			"vitality": permanent_vitality,
			"energy": permanent_energy,
		},

		"bonus_stat_points": bonus_stat_points,

		"budget": {
			"points_per_level": (
				stat_points_per_level
			),

			"points_per_reset": (
				stat_points_per_reset
			),

			"level_points": level_points,

			"reset_points": reset_points,

			"bonus_points": (
				bonus_stat_points
			),

			"total_points": total_points,

			"spent_points": spent_points,

			"unspent_points": unspent_points,
		},
	}
