class_name EquipmentSlotCatalog
extends RefCounted


# =========================================================
# IDENTIDAD ESTABLE
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
# SLOTS
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
# AUTO EQUIP
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
# CATEGORÍAS ESTRUCTURALMENTE ACEPTADAS
# =========================================================
#
# Esto sólo expresa compatibilidad SLOT <-> CATEGORY.
#
# Las reglas de manos viven en EquipmentRules.
# =========================================================

const ALLOWED_CATEGORIES_BY_SLOT_ID: Dictionary = {
	HEAD: [
		EquipmentCategoryCatalog.HEAD,
	],

	CHEST: [
		EquipmentCategoryCatalog.CHEST,
	],

	PANTS: [
		EquipmentCategoryCatalog.PANTS,
	],

	GLOVES: [
		EquipmentCategoryCatalog.GLOVES,
	],

	BOOTS: [
		EquipmentCategoryCatalog.BOOTS,
	],

	MAIN_HAND: [
		EquipmentCategoryCatalog.WEAPON,
	],

	OFF_HAND: [
		EquipmentCategoryCatalog.WEAPON,
		EquipmentCategoryCatalog.SHIELD,
	],

	WINGS: [
		EquipmentCategoryCatalog.WINGS,
	],

	PENDANT: [
		EquipmentCategoryCatalog.PENDANT,
	],

	RING_LEFT: [
		EquipmentCategoryCatalog.RING,
	],

	RING_RIGHT: [
		EquipmentCategoryCatalog.RING,
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


	return ALLOWED_CATEGORIES_BY_SLOT_ID.has(
		normalized
	)


# =========================================================
# MANOS
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
# CATEGORÍAS
# =========================================================

static func get_allowed_categories(
	slot_id: Variant
) -> Array[StringName]:
	var normalized := (
		normalize_slot_id(
			slot_id
		)
	)


	if not ALLOWED_CATEGORIES_BY_SLOT_ID.has(
		normalized
	):
		return []


	var value: Variant = (
		ALLOWED_CATEGORIES_BY_SLOT_ID[
			normalized
		]
	)


	if typeof(value) != TYPE_ARRAY:
		return []


	var result: Array[StringName] = []


	for category_value: Variant in value:
		result.append(
			EquipmentCategoryCatalog.normalize_category_id(
				category_value
			)
		)


	return result


static func accepts_category(
	slot_id: Variant,
	category_id: Variant
) -> bool:
	var normalized_category := (
		EquipmentCategoryCatalog.normalize_category_id(
			category_id
		)
	)


	return get_allowed_categories(
		slot_id
	).has(
		normalized_category
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


	if not EquipmentCategoryCatalog.validate_catalog():
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


		if not ALLOWED_CATEGORIES_BY_SLOT_ID.has(
			slot_id
		):
			return false


		var allowed_categories := (
			get_allowed_categories(
				slot_id
			)
		)


		if allowed_categories.is_empty():
			return false


		for category_id: StringName in allowed_categories:
			if not EquipmentCategoryCatalog.is_equipment_category(
				category_id
			):
				return false


	if (
		seen.size()
		!=
		ALLOWED_CATEGORIES_BY_SLOT_ID.size()
	):
		return false


	return true
