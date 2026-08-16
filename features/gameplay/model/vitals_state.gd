class_name VitalsState
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

signal hp_changed(
	current: int,
	maximum: int
)

signal mp_changed(
	current: int,
	maximum: int
)


# =========================================================
# HP
# =========================================================

var hp: int = 1

var max_hp: int = 1


# =========================================================
# MP
# =========================================================

var mp: int = 1

var max_mp: int = 1


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	initial_max_hp: int = 1,
	initial_hp: int = -1,
	initial_max_mp: int = 1,
	initial_mp: int = -1
) -> void:
	max_hp = maxi(
		initial_max_hp,
		1
	)


	if initial_hp < 0:
		hp = max_hp
	else:
		hp = clampi(
			initial_hp,
			0,
			max_hp
		)


	max_mp = maxi(
		initial_max_mp,
		1
	)


	if initial_mp < 0:
		mp = max_mp
	else:
		mp = clampi(
			initial_mp,
			0,
			max_mp
		)


# =========================================================
# HP
# =========================================================

func set_hp(
	value: int
) -> void:
	var new_value := clampi(
		value,
		0,
		max_hp
	)


	if hp == new_value:
		return


	hp = new_value


	hp_changed.emit(
		hp,
		max_hp
	)


func set_max_hp(
	value: int
) -> void:
	var new_maximum := maxi(
		value,
		1
	)


	if (
		max_hp == new_maximum
		and
		hp <= new_maximum
	):
		return


	max_hp = new_maximum

	hp = mini(
		hp,
		max_hp
	)


	hp_changed.emit(
		hp,
		max_hp
	)


# =========================================================
# MP
# =========================================================

func set_mp(
	value: int
) -> void:
	var new_value := clampi(
		value,
		0,
		max_mp
	)


	if mp == new_value:
		return


	mp = new_value


	mp_changed.emit(
		mp,
		max_mp
	)


func set_max_mp(
	value: int
) -> void:
	var new_maximum := maxi(
		value,
		1
	)


	if (
		max_mp == new_maximum
		and
		mp <= new_maximum
	):
		return


	max_mp = new_maximum

	mp = mini(
		mp,
		max_mp
	)


	mp_changed.emit(
		mp,
		max_mp
	)
