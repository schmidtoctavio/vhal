class_name EquipmentSlotCatalog
extends RefCounted


# =========================================================
# IDENTIDAD ESTABLE
# =========================================================
#
# Estos IDs son la identidad canónica de los slots.
#
# Deben poder utilizarse sin traducción en:
#
# - Runtime
# - UI
# - ENet
# - Game Server
# - Backend
# - Database
# - Snapshots
#
# Nunca utilizar ordinales numéricos como identidad
# persistente o de red.
# =========================================================

const INVALID_SLOT_ID: StringName = &""


const HEAD: StringName = &"head"

const CHEST: StringName = &"chest"

const PANTS: StringName = &"pants"

const GLOVES: StringName = &"gloves"

const BOOTS: StringName = &"boots"


const MAIN_HAND: StringName = &"main_hand"

const OFF_HAND: StringName = &"off_hand"


const WINGS: StringName = &"wings"

const PENDANT: StringName = &"pendant"


const RING_LEFT: StringName = &"ring_left"

const RING_RIGHT: StringName = &"ring_right"


# =========================================================
# SLOTS EXISTENTES
# =========================================================

const SLOT_IDS: Array[StringName] = [
	HEAD,
	CHEST,
	PANTS,
	GLOVES,
	BOOTS,

	MAIN_HAND,
	OFF_HAND,

	WINGS,
	PENDANT,

	RING_LEFT,
	RING_RIGHT,
]


# =========================================================
# PRIORIDAD DE AUTO-EQUIP
# =========================================================
#
# Es solamente prioridad de búsqueda.
#
# No define si el item realmente puede equiparse ahí.
# =========================================================

const AUTO_EQUIP_PRIORITY: Array[StringName] = [
	HEAD,
	CHEST,
	PANTS,
	GLOVES,
	BOOTS,

	MAIN_HAND,
	OFF_HAND,

	WINGS,
	PENDANT,

	RING_LEFT,
	RING_RIGHT,
]


# =========================================================
# TIPOS ACEPTADOS
# =========================================================
#
# Por ahora MAIN_HAND y OFF_HAND aceptan WEAPON.
#
# En B1R2 agregaremos semántica de:
#
# - one hand
# - two hand
# - main hand only
# - off hand only
# - shield
#
# sin cambiar estos IDs.
# =========================================================

const ALLOWED_EQUIPMENT_TYPES_BY_SLOT_ID: Dictionary = {
	HEAD: [
		ItemDefinition.EquipmentType.HEAD,
	],

	CHEST: [
		ItemDefinition.EquipmentType.CHEST,
	],

	PANTS: [
		ItemDefinition.EquipmentType.PANTS,
	],

	GLOVES: [
		ItemDefinition.EquipmentType.GLOVES,
	],

	BOOTS: [
		ItemDefinition.EquipmentType.BOOTS,
	],

	MAIN_HAND: [
		ItemDefinition.EquipmentType.WEAPON,
	],

	OFF_HAND: [
		ItemDefinition.EquipmentType.WEAPON,
	],

	WINGS: [
		ItemDefinition.EquipmentType.WINGS,
	],

	PENDANT: [
		ItemDefinition.EquipmentType.PENDANT,
	],

	RING_LEFT: [
		ItemDefinition.EquipmentType.RING,
	],

	RING_RIGHT: [
		ItemDefinition.EquipmentType.RING,
	],
}


# =========================================================
# NORMALIZACIÓN
# =========================================================

static func normalize_slot_id(
	slot_id: Variant
) -> StringName:
	return StringName(
		String(
			slot_id
		)
		.strip_edges()
		.to_lower()
	)


# =========================================================
# VALIDACIÓN
# =========================================================

static func is_valid_slot_id(
	slot_id: Variant
) -> bool:
	var normalized := (
		normalize_slot_id(
			slot_id
		)
	)


	if normalized == INVALID_SLOT_ID:
		return false


	return ALLOWED_EQUIPMENT_TYPES_BY_SLOT_ID.has(
		normalized
	)


# =========================================================
# SLOTS DE MANO
# =========================================================

static func is_hand_slot(
	slot_id: Variant
) -> bool:
	var normalized := (
		normalize_slot_id(
			slot_id
		)
	)


	return (
		normalized == MAIN_HAND
		or
		normalized == OFF_HAND
	)


# =========================================================
# TIPOS ACEPTADOS
# =========================================================

static func get_allowed_equipment_types(
	slot_id: Variant
) -> Array[int]:
	var normalized := (
		normalize_slot_id(
			slot_id
		)
	)


	if not ALLOWED_EQUIPMENT_TYPES_BY_SLOT_ID.has(
		normalized
	):
		return []


	var value: Variant = (
		ALLOWED_EQUIPMENT_TYPES_BY_SLOT_ID[
			normalized
		]
	)


	if typeof(value) != TYPE_ARRAY:
		return []


	var result: Array[int] = []


	for equipment_type in value:
		result.append(
			int(
				equipment_type
			)
		)


	return result


static func accepts_equipment_type(
	slot_id: Variant,
	equipment_type: int
) -> bool:
	var allowed_types := (
		get_allowed_equipment_types(
			slot_id
		)
	)


	return allowed_types.has(
		equipment_type
	)


# =========================================================
# AUTO EQUIP
# =========================================================

static func get_auto_equip_priority() -> Array[StringName]:
	return AUTO_EQUIP_PRIORITY.duplicate()


# =========================================================
# TODOS LOS IDS
# =========================================================

static func get_slot_ids() -> Array[StringName]:
	return SLOT_IDS.duplicate()


# =========================================================
# SELF VALIDATION
# =========================================================

static func validate_catalog() -> bool:
	if SLOT_IDS.is_empty():
		return false


	var seen: Dictionary = {}


	for slot_id: StringName in SLOT_IDS:
		if slot_id == INVALID_SLOT_ID:
			return false


		if seen.has(
			slot_id
		):
			return false


		seen[
			slot_id
		] = true


		if not ALLOWED_EQUIPMENT_TYPES_BY_SLOT_ID.has(
			slot_id
		):
			return false


		var allowed_types := (
			get_allowed_equipment_types(
				slot_id
			)
		)


		if allowed_types.is_empty():
			return false


		for equipment_type: int in allowed_types:
			if (
				equipment_type
				==
				ItemDefinition.EquipmentType.NONE
			):
				return false


	if (
		seen.size()
		!=
		ALLOWED_EQUIPMENT_TYPES_BY_SLOT_ID.size()
	):
		return false


	return true
