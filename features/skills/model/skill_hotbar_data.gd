class_name SkillHotbarData
extends RefCounted


# =========================================================
# CONFIGURACIÓN
# =========================================================

const SLOT_COUNT: int = 3


# =========================================================
# SEÑALES
# =========================================================

signal slot_changed(
	index: int,
	skill: SkillDefinition
)

signal selection_changed(
	index: int,
	skill: SkillDefinition
)


# =========================================================
# ESTADO
# =========================================================

var _slots: Array[SkillDefinition] = []

var selected_index: int = 0


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init() -> void:
	_slots.resize(
		SLOT_COUNT
	)


# =========================================================
# VALIDACIÓN
# =========================================================

func is_valid_index(
	index: int
) -> bool:
	return (
		index >= 0
		and
		index < SLOT_COUNT
	)


# =========================================================
# CONSULTAR SLOT
# =========================================================

func get_skill(
	index: int
) -> SkillDefinition:
	if not is_valid_index(
		index
	):
		return null

	return _slots[index]


# =========================================================
# ASIGNAR SKILL
# =========================================================

func set_skill(
	index: int,
	skill: SkillDefinition
) -> bool:
	if not is_valid_index(
		index
	):
		return false


	if _slots[index] == skill:
		return true


	_slots[index] = skill


	slot_changed.emit(
		index,
		skill
	)


	if selected_index == index:
		selection_changed.emit(
			selected_index,
			skill
		)


	return true


# =========================================================
# LIMPIAR SLOT
# =========================================================

func clear_slot(
	index: int
) -> bool:
	return set_skill(
		index,
		null
	)


# =========================================================
# SELECCIONAR SLOT
# =========================================================

func select_slot(
	index: int
) -> bool:
	if not is_valid_index(
		index
	):
		return false


	if selected_index == index:
		return true


	selected_index = index


	selection_changed.emit(
		selected_index,
		get_selected_skill()
	)


	return true


# =========================================================
# SKILL SELECCIONADA
# =========================================================

func get_selected_skill() -> SkillDefinition:
	return get_skill(
		selected_index
	)


# =========================================================
# BUSCAR SKILL
# =========================================================

func find_skill_index(
	skill: SkillDefinition
) -> int:
	if skill == null:
		return -1


	for index in range(
		SLOT_COUNT
	):
		if _slots[index] == skill:
			return index


	return -1
