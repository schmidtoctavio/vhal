class_name ExperienceState
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

signal experience_changed(
	current: int,
	required: int
)


# =========================================================
# ESTADO
# =========================================================

var experience: int = 0

var experience_required: int = 1


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	initial_required: int = 1,
	initial_experience: int = 0
) -> void:
	experience_required = maxi(
		initial_required,
		1
	)


	experience = clampi(
		initial_experience,
		0,
		experience_required
	)


# =========================================================
# EXPERIENCIA
# =========================================================

func set_experience(
	value: int
) -> void:
	var new_value := clampi(
		value,
		0,
		experience_required
	)


	if experience == new_value:
		return


	experience = new_value


	experience_changed.emit(
		experience,
		experience_required
	)


func set_experience_required(
	value: int
) -> void:
	var new_required := maxi(
		value,
		1
	)


	if (
		experience_required == new_required
		and
		experience <= new_required
	):
		return


	experience_required = new_required


	experience = mini(
		experience,
		experience_required
	)


	experience_changed.emit(
		experience,
		experience_required
	)
