class_name EquipmentData
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

signal item_equipped(
	slot_id: StringName,
	item: ItemInstance
)

signal item_unequipped(
	slot_id: StringName,
	item: ItemInstance
)


# =========================================================
# ESTADO
# =========================================================
#
# StringName -> ItemInstance
#
# Ejemplo:
#
# &"head"      -> Leather Helmet
# &"main_hand" -> Bronze Sword
# =========================================================

var _equipped: Dictionary = {}


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init() -> void:
	assert(
		EquipmentRules.validate_contract(),
		(
			"EquipmentData | "
			+
			"Equipment Domain Contract inválido."
		)
	)

# =========================================================
# CONSULTAS
# =========================================================

func get_item(
	slot_id: Variant
) -> ItemInstance:
	var normalized := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not EquipmentSlotCatalog.is_valid_slot_id(
		normalized
	):
		return null


	var item: Variant = (
		_equipped.get(
			normalized,
			null
		)
	)


	if item is ItemInstance:
		return item as ItemInstance


	return null


func is_slot_empty(
	slot_id: Variant
) -> bool:
	return get_item(
		slot_id
	) == null


func contains_item(
	item: ItemInstance
) -> bool:
	if item == null:
		return false


	for equipped_item in _equipped.values():
		if equipped_item == item:
			return true


	return false


func get_slot_of_item(
	item: ItemInstance
) -> StringName:
	if item == null:
		return EquipmentSlotCatalog.INVALID_SLOT_ID


	for slot_key in _equipped.keys():
		if _equipped[
			slot_key
		] == item:
			return EquipmentSlotCatalog.normalize_slot_id(
				slot_key
			)


	return EquipmentSlotCatalog.INVALID_SLOT_ID


func get_equipped_items() -> Dictionary:
	return _equipped.duplicate()


# =========================================================
# VALIDACIÓN
# =========================================================

func can_equip(
	slot_id: Variant,
	item: ItemInstance
) -> bool:
	return EquipmentRules.can_equip(
		_equipped,
		item,
		slot_id
	)


# =========================================================
# EQUIPAR
# =========================================================

func equip_item(
	slot_id: Variant,
	item: ItemInstance
) -> bool:
	var normalized := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not can_equip(
		normalized,
		item
	):
		return false


	_equipped[
		normalized
	] = item


	item_equipped.emit(
		normalized,
		item
	)


	return true


# =========================================================
# DESEQUIPAR
# =========================================================

func unequip_item(
	slot_id: Variant
) -> ItemInstance:
	var normalized := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not EquipmentSlotCatalog.is_valid_slot_id(
		normalized
	):
		return null


	var item := get_item(
		normalized
	)


	if item == null:
		return null


	_equipped.erase(
		normalized
	)


	item_unequipped.emit(
		normalized,
		item
	)


	return item


# =========================================================
# INVENTORY -> EQUIPMENT
# =========================================================
#
# TRANSITORIO:
#
# Esta operación sigue existiendo para el modo local.
#
# Cuando F15-B llegue al flujo autoritativo completo,
# Inventory -> Equipment dejará de mutarse localmente.
# =========================================================

func equip_from_inventory(
	source_inventory: InventoryData,
	item: ItemInstance,
	slot_id: Variant
) -> bool:
	if source_inventory == null:
		return false


	if item == null:
		return false


	if not source_inventory.items.has(
		item
	):
		return false


	var normalized := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not can_equip(
		normalized,
		item
	):
		return false


	var old_position := (
		item.grid_position
	)


	if not source_inventory.remove_item(
		item
	):
		return false


	if equip_item(
		normalized,
		item
	):
		return true


	# -----------------------------------------------------
	# ROLLBACK
	# -----------------------------------------------------

	item.grid_position = old_position


	source_inventory.add_item(
		item
	)


	return false


# =========================================================
# EQUIPMENT -> INVENTORY
# =========================================================
#
# TRANSITORIO:
#
# Igual que equip_from_inventory(), desaparecerá del flujo
# autoritativo cuando el servidor sea quien confirme el
# transfer.
# =========================================================

func unequip_to_inventory(
	target_inventory: InventoryData,
	slot_id: Variant,
	new_position: Vector2i
) -> bool:
	if target_inventory == null:
		return false


	var normalized := (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not EquipmentSlotCatalog.is_valid_slot_id(
		normalized
	):
		return false


	var item := get_item(
		normalized
	)


	if item == null:
		return false


	if not target_inventory.can_place_item(
		item,
		new_position
	):
		return false


	var old_position := (
		item.grid_position
	)


	# -----------------------------------------------------
	# Quitamos temporalmente del Equipment sin emitir
	# todavía la señal.
	# -----------------------------------------------------

	_equipped.erase(
		normalized
	)


	item.grid_position = (
		new_position
	)


	if not target_inventory.add_item(
		item
	):
		# -------------------------------------------------
		# ROLLBACK
		# -------------------------------------------------

		item.grid_position = (
			old_position
		)


		_equipped[
			normalized
		] = item


		return false


	item_unequipped.emit(
		normalized,
		item
	)


	return true


# =========================================================
# AUTO EQUIP
# =========================================================

func find_first_compatible_empty_slot(
	item: ItemInstance
) -> StringName:
	if (
		item == null
		or
		not item.is_valid()
	):
		return EquipmentSlotCatalog.INVALID_SLOT_ID


	var priority := (
		EquipmentSlotCatalog.get_auto_equip_priority()
	)


	for slot_id: StringName in priority:
		if can_equip(
			slot_id,
			item
		):
			return slot_id


	return EquipmentSlotCatalog.INVALID_SLOT_ID

func is_slot_reserved(
	slot_id: Variant
) -> bool:
	return EquipmentRules.is_slot_reserved(
		_equipped,
		slot_id
	)


func get_reserving_item(
	slot_id: Variant
) -> ItemInstance:
	return EquipmentRules.get_reserving_item(
		_equipped,
		slot_id
	)


func is_slot_available(
	slot_id: Variant
) -> bool:
	return (
		is_slot_empty(
			slot_id
		)
		and
		not is_slot_reserved(
			slot_id
		)
	)
