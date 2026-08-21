class_name EquipmentRules
extends RefCounted


# =========================================================
# CONTRACT SELF TEST
# =========================================================

static func validate_contract() -> bool:
	if not EquipmentCategoryCatalog.validate_catalog():
		return false


	if not HandEquipModeCatalog.validate_catalog():
		return false


	if not EquipmentSlotCatalog.validate_catalog():
		return false


	# -----------------------------------------------------
	# MAIN HAND ONLY
	# -----------------------------------------------------

	if not _hand_mode_allows_slot(
		HandEquipModeCatalog.MAIN_HAND_ONLY,
		EquipmentSlotCatalog.MAIN_HAND
	):
		return false


	if _hand_mode_allows_slot(
		HandEquipModeCatalog.MAIN_HAND_ONLY,
		EquipmentSlotCatalog.OFF_HAND
	):
		return false


	# -----------------------------------------------------
	# ONE HAND
	# -----------------------------------------------------

	if not _hand_mode_allows_slot(
		HandEquipModeCatalog.ONE_HAND,
		EquipmentSlotCatalog.MAIN_HAND
	):
		return false


	if not _hand_mode_allows_slot(
		HandEquipModeCatalog.ONE_HAND,
		EquipmentSlotCatalog.OFF_HAND
	):
		return false


	# -----------------------------------------------------
	# TWO HAND
	# -----------------------------------------------------

	if not _hand_mode_allows_slot(
		HandEquipModeCatalog.TWO_HAND,
		EquipmentSlotCatalog.MAIN_HAND
	):
		return false


	if _hand_mode_allows_slot(
		HandEquipModeCatalog.TWO_HAND,
		EquipmentSlotCatalog.OFF_HAND
	):
		return false


	# -----------------------------------------------------
	# OFF HAND ONLY
	# -----------------------------------------------------

	if _hand_mode_allows_slot(
		HandEquipModeCatalog.OFF_HAND_ONLY,
		EquipmentSlotCatalog.MAIN_HAND
	):
		return false


	if not _hand_mode_allows_slot(
		HandEquipModeCatalog.OFF_HAND_ONLY,
		EquipmentSlotCatalog.OFF_HAND
	):
		return false


	# -----------------------------------------------------
	# SHIELD
	# -----------------------------------------------------

	if EquipmentSlotCatalog.accepts_category(
		EquipmentSlotCatalog.MAIN_HAND,
		EquipmentCategoryCatalog.SHIELD
	):
		return false


	if not EquipmentSlotCatalog.accepts_category(
		EquipmentSlotCatalog.OFF_HAND,
		EquipmentCategoryCatalog.SHIELD
	):
		return false


	return true


# =========================================================
# DEFINICIÓN
# =========================================================

static func is_definition_configuration_valid(
	definition: ItemDefinition
) -> bool:
	if definition == null:
		return false


	if not definition.is_equipment():
		return false


	var category_id := (
		definition.get_equipment_category_id()
	)


	var hand_mode_id := (
		definition.get_hand_equip_mode_id()
	)


	if not EquipmentCategoryCatalog.is_equipment_category(
		category_id
	):
		return false


	if not HandEquipModeCatalog.is_valid_mode_id(
		hand_mode_id
	):
		return false


	# -----------------------------------------------------
	# ITEMS DE MANO
	# -----------------------------------------------------

	if EquipmentCategoryCatalog.is_hand_category(
		category_id
	):
		if hand_mode_id == HandEquipModeCatalog.NONE:
			return false


		# Un shield, en la primera versión del dominio,
		# es exclusivamente off-hand.
		if (
			category_id
			==
			EquipmentCategoryCatalog.SHIELD
		):
			return (
				hand_mode_id
				==
				HandEquipModeCatalog.OFF_HAND_ONLY
			)


		return true


	# -----------------------------------------------------
	# EQUIPMENT NO RELACIONADO CON MANOS
	# -----------------------------------------------------

	return (
		hand_mode_id
		==
		HandEquipModeCatalog.NONE
	)


# =========================================================
# DEFINICIÓN -> SLOT
# =========================================================

static func can_definition_use_slot(
	definition: ItemDefinition,
	slot_id: Variant
) -> bool:
	if not is_definition_configuration_valid(
		definition
	):
		return false


	var normalized_slot := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not EquipmentSlotCatalog.is_valid_slot_id(
		normalized_slot
	):
		return false


	var category_id := (
		definition.get_equipment_category_id()
	)


	if not EquipmentSlotCatalog.accepts_category(
		normalized_slot,
		category_id
	):
		return false


	# -----------------------------------------------------
	# SLOT NO RELACIONADO CON MANOS
	# -----------------------------------------------------

	if not EquipmentSlotCatalog.is_hand_slot(
		normalized_slot
	):
		return true


	var hand_mode_id := (
		definition.get_hand_equip_mode_id()
	)


	return _hand_mode_allows_slot(
		hand_mode_id,
		normalized_slot
	)


# =========================================================
# REGLAS DE HAND MODE
# =========================================================

static func _hand_mode_allows_slot(
	hand_mode_id: Variant,
	slot_id: Variant
) -> bool:
	var normalized_mode := (
		HandEquipModeCatalog.normalize_mode_id(
			hand_mode_id
		)
	)


	var normalized_slot := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	match normalized_mode:
		HandEquipModeCatalog.MAIN_HAND_ONLY:
			return (
				normalized_slot
				==
				EquipmentSlotCatalog.MAIN_HAND
			)


		HandEquipModeCatalog.ONE_HAND:
			return (
				normalized_slot
				==
				EquipmentSlotCatalog.MAIN_HAND
				or
				normalized_slot
				==
				EquipmentSlotCatalog.OFF_HAND
			)


		HandEquipModeCatalog.TWO_HAND:
			return (
				normalized_slot
				==
				EquipmentSlotCatalog.MAIN_HAND
			)


		HandEquipModeCatalog.OFF_HAND_ONLY:
			return (
				normalized_slot
				==
				EquipmentSlotCatalog.OFF_HAND
			)


	return false


# =========================================================
# SLOTS RESERVADOS POR UN ITEM
# =========================================================

static func get_reserved_slot_ids(
	item: ItemInstance,
	equipped_slot_id: Variant
) -> Array[StringName]:
	var result: Array[StringName] = []


	if (
		item == null
		or
		not item.is_valid()
	):
		return result


	var normalized_slot := (
		EquipmentSlotCatalog.normalize_slot_id(
			equipped_slot_id
		)
	)


	if (
		normalized_slot
		!=
		EquipmentSlotCatalog.MAIN_HAND
	):
		return result


	if (
		item.definition.get_hand_equip_mode_id()
		!=
		HandEquipModeCatalog.TWO_HAND
	):
		return result


	result.append(
		EquipmentSlotCatalog.OFF_HAND
	)


	return result


# =========================================================
# ITEM QUE RESERVA UN SLOT
# =========================================================

static func get_reserving_item(
	equipped: Dictionary,
	slot_id: Variant
) -> ItemInstance:
	var normalized_target := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not EquipmentSlotCatalog.is_valid_slot_id(
		normalized_target
	):
		return null


	for source_slot_value: Variant in equipped.keys():
		var source_slot := (
			EquipmentSlotCatalog.normalize_slot_id(
				source_slot_value
			)
		)


		var item_value: Variant = (
			equipped[
				source_slot_value
			]
		)


		if not (
			item_value is ItemInstance
		):
			continue


		var item := (
			item_value as ItemInstance
		)


		var reserved_slots := (
			get_reserved_slot_ids(
				item,
				source_slot
			)
		)


		if reserved_slots.has(
			normalized_target
		):
			return item


	return null


static func is_slot_reserved(
	equipped: Dictionary,
	slot_id: Variant
) -> bool:
	return (
		get_reserving_item(
			equipped,
			slot_id
		)
		!=
		null
	)


# =========================================================
# VALIDAR ESTADO COMPLETO
# =========================================================

static func validate_equipment_state(
	equipped: Dictionary
) -> bool:
	var normalized_items: Dictionary = {}

	var seen_instances: Dictionary = {}


	for slot_value: Variant in equipped.keys():
		var normalized_slot := (
			EquipmentSlotCatalog.normalize_slot_id(
				slot_value
			)
		)


		if not EquipmentSlotCatalog.is_valid_slot_id(
			normalized_slot
		):
			return false


		if normalized_items.has(
			normalized_slot
		):
			return false


		var item_value: Variant = (
			equipped[
				slot_value
			]
		)


		if not (
			item_value is ItemInstance
		):
			return false


		var item := (
			item_value as ItemInstance
		)


		if not item.is_valid():
			return false


		var instance_id := (
			item.get_instance_id()
		)


		if seen_instances.has(
			instance_id
		):
			return false


		seen_instances[
			instance_id
		] = true


		if not can_definition_use_slot(
			item.definition,
			normalized_slot
		):
			return false


		normalized_items[
			normalized_slot
		] = item


	# -----------------------------------------------------
	# VALIDAR RESERVAS
	# -----------------------------------------------------

	for source_slot_value: Variant in normalized_items.keys():
		var source_slot := (
			EquipmentSlotCatalog.normalize_slot_id(
				source_slot_value
			)
		)


		var item := (
			normalized_items[
				source_slot_value
			]
			as ItemInstance
		)


		var reserved_slots := (
			get_reserved_slot_ids(
				item,
				source_slot
			)
		)


		for reserved_slot: StringName in reserved_slots:
			if normalized_items.has(
				reserved_slot
			):
				return false


	return true


# =========================================================
# PUEDE EQUIPARSE
# =========================================================

static func can_equip(
	equipped: Dictionary,
	item: ItemInstance,
	slot_id: Variant
) -> bool:
	if (
		item == null
		or
		not item.is_valid()
	):
		return false


	var normalized_slot := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not EquipmentSlotCatalog.is_valid_slot_id(
		normalized_slot
	):
		return false


	if equipped.has(
		normalized_slot
	):
		return false


	if is_slot_reserved(
		equipped,
		normalized_slot
	):
		return false


	if not can_definition_use_slot(
		item.definition,
		normalized_slot
	):
		return false


	var candidate := (
		equipped.duplicate()
	)


	candidate[
		normalized_slot
	] = item


	return validate_equipment_state(
		candidate
	)
