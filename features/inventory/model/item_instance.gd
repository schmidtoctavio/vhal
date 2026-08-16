class_name ItemInstance
extends RefCounted


# =========================================================
# IDENTIDAD
# =========================================================

var uid: String = ""


# =========================================================
# DEFINICIÓN
# =========================================================

var definition: ItemDefinition = null


# =========================================================
# ESTADO
# =========================================================

var quantity: int = 1

var grid_position: Vector2i = Vector2i.ZERO


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	new_definition: ItemDefinition = null,
	new_quantity: int = 1,
	new_grid_position: Vector2i = Vector2i.ZERO,
	new_uid: String = ""
) -> void:
	definition = new_definition

	grid_position = new_grid_position

	uid = new_uid


	if definition != null:
		quantity = clampi(
			new_quantity,
			1,
			get_max_stack()
		)
	else:
		quantity = maxi(
			new_quantity,
			1
		)


# =========================================================
# GRID
# =========================================================

func get_grid_size() -> Vector2i:
	if definition == null:
		return Vector2i.ONE

	return definition.get_grid_size()


# =========================================================
# STACK
# =========================================================

func get_max_stack() -> int:
	if definition == null:
		return 1

	return maxi(
		definition.max_stack,
		1
	)


func is_stackable() -> bool:
	return (
		definition != null
		and
		get_max_stack() > 1
	)


func can_stack_with(
	other: ItemInstance
) -> bool:
	if other == null:
		return false

	if other == self:
		return false

	if definition == null:
		return false

	if other.definition == null:
		return false

	if not is_stackable():
		return false

	if not other.is_stackable():
		return false


	# -----------------------------------------------------
	# Comparamos por ID lógico.
	#
	# No alcanza con que ambos sean CONSUMABLE.
	# Deben ser exactamente el mismo tipo de item.
	# -----------------------------------------------------

	return (
		definition.item_id
		==
		other.definition.item_id
	)


func get_remaining_stack_space() -> int:
	return maxi(
		get_max_stack() - quantity,
		0
	)


func is_stack_full() -> bool:
	return (
		quantity >= get_max_stack()
	)


# =========================================================
# VALIDACIÓN
# =========================================================

func is_valid() -> bool:
	return definition != null
