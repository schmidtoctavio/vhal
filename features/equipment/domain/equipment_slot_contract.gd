class_name EquipmentSlotContract
extends RefCounted


# =========================================================
# IDS ESTABLES
# =========================================================
#
# IMPORTANTE:
#
# Estos valores forman parte del contrato lógico de VHAL.
#
# Pueden utilizarse en:
#
# - Game Server
# - Backend
# - Database
# - Networking
# - Snapshots
#
# NO deben reemplazarse por los valores numéricos de enums.
# =========================================================

const INVALID_SLOT_ID: StringName = &""


const HEAD: StringName = &"head"

const CHEST: StringName = &"chest"

const PANTS: StringName = &"pants"

const GLOVES: StringName = &"gloves"

const BOOTS: StringName = &"boots"


const WEAPON_LEFT: StringName = &"weapon_left"

const WEAPON_RIGHT: StringName = &"weapon_right"


const WINGS: StringName = &"wings"

const PENDANT: StringName = &"pendant"


const RING_LEFT: StringName = &"ring_left"

const RING_RIGHT: StringName = &"ring_right"


# =========================================================
# TODOS LOS SLOTS
# =========================================================

const SLOT_IDS: Array[StringName] = [
	HEAD,
	CHEST,
	PANTS,
	GLOVES,
	BOOTS,

	WEAPON_LEFT,
	WEAPON_RIGHT,

	WINGS,
	PENDANT,

	RING_LEFT,
	RING_RIGHT,
]


# =========================================================
# TIPO DE EQUIPMENT ACEPTADO
# =========================================================
#
# Esta tabla describe una propiedad DEL SLOT.
#
# No describe todavía:
#
# - clase permitida
# - nivel mínimo
# - stats requeridas
# - arma de dos manos
# - dual wield
# - restricciones especiales
#
# Esas reglas tendrán sus propias capas cuando existan.
# =========================================================

const REQUIRED_EQUIPMENT_TYPE_BY_SLOT_ID: Dictionary = {
	HEAD:
		ItemDefinition.EquipmentType.HEAD,

	CHEST:
		ItemDefinition.EquipmentType.CHEST,

	PANTS:
		ItemDefinition.EquipmentType.PANTS,

	GLOVES:
		ItemDefinition.EquipmentType.GLOVES,

	BOOTS:
		ItemDefinition.EquipmentType.BOOTS,

	WEAPON_LEFT:
		ItemDefinition.EquipmentType.WEAPON,

	WEAPON_RIGHT:
		ItemDefinition.EquipmentType.WEAPON,

	WINGS:
		ItemDefinition.EquipmentType.WINGS,

	PENDANT:
		ItemDefinition.EquipmentType.PENDANT,

	RING_LEFT:
		ItemDefinition.EquipmentType.RING,

	RING_RIGHT:
		ItemDefinition.EquipmentType.RING,
}


# =========================================================
# NORMALIZAR ID
# =========================================================

static func normalize_slot_id(
	slot_id: String
) -> StringName:
	return StringName(
		slot_id
		.strip_edges()
		.to_lower()
	)


# =========================================================
# VALIDAR ID
# =========================================================

static func is_valid_slot_id(
	slot_id: String
) -> bool:
	var normalized := (
		normalize_slot_id(
			slot_id
		)
	)


	if normalized == INVALID_SLOT_ID:
		return false


	return REQUIRED_EQUIPMENT_TYPE_BY_SLOT_ID.has(
		normalized
	)


# =========================================================
# OBTENER TIPO REQUERIDO
# =========================================================

static func get_required_equipment_type(
	slot_id: String
) -> ItemDefinition.EquipmentType:
	var normalized := (
		normalize_slot_id(
			slot_id
		)
	)


	if not REQUIRED_EQUIPMENT_TYPE_BY_SLOT_ID.has(
		normalized
	):
		return ItemDefinition.EquipmentType.NONE


	return int(
		REQUIRED_EQUIPMENT_TYPE_BY_SLOT_ID[
			normalized
		]
	) as ItemDefinition.EquipmentType


# =========================================================
# VALIDAR DEFINICIÓN CONTRA SLOT
# =========================================================

static func accepts_definition(
	slot_id: String,
	definition: ItemDefinition
) -> bool:
	if definition == null:
		return false


	if not definition.is_equipment():
		return false


	var required_type := (
		get_required_equipment_type(
			slot_id
		)
	)


	if required_type == ItemDefinition.EquipmentType.NONE:
		return false


	return (
		definition.equipment_type
		==
		required_type
	)


# =========================================================
# OBTENER TODOS LOS IDS
# =========================================================

static func get_slot_ids() -> Array[StringName]:
	return SLOT_IDS.duplicate()


# =========================================================
# SELF-VALIDATION
# =========================================================
#
# Esto valida invariantes estructurales del contrato.
#
# Si alguien agrega un slot nuevo en SLOT_IDS y olvida
# agregar su metadata, queremos descubrirlo inmediatamente.
# =========================================================

static func validate_contract() -> bool:
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


		if not REQUIRED_EQUIPMENT_TYPE_BY_SLOT_ID.has(
			slot_id
		):
			return false


		var equipment_type := int(
			REQUIRED_EQUIPMENT_TYPE_BY_SLOT_ID[
				slot_id
			]
		)


		if equipment_type == ItemDefinition.EquipmentType.NONE:
			return false


	if (
		seen.size()
		!=
		REQUIRED_EQUIPMENT_TYPE_BY_SLOT_ID.size()
	):
		return false


	return true
