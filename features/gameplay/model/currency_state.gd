class_name CurrencyState
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

signal zen_changed(
	amount: int
)


# =========================================================
# ESTADO
# =========================================================

var zen: int = 0


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	initial_zen: int = 0
) -> void:
	zen = maxi(
		initial_zen,
		0
	)


# =========================================================
# MODIFICAR
# =========================================================

func set_zen(
	amount: int
) -> void:
	var new_amount := maxi(
		amount,
		0
	)


	if zen == new_amount:
		return


	zen = new_amount


	zen_changed.emit(
		zen
	)
