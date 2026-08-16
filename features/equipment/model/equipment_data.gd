class_name EquipmentData
extends RefCounted


# =========================================================
# SLOTS FÍSICOS DEL PERSONAJE
# =========================================================

enum Slot {
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
	RING_RIGHT
}


# =========================================================
# SEÑALES
# =========================================================

signal item_equipped(
	slot: Slot,
	item: ItemInstance
)

signal item_unequipped(
	slot: Slot,
	item: ItemInstance
)


# =========================================================
# ESTADO
# =========================================================

# Slot -> ItemInstance
#
# Ejemplo:
#
# HEAD         -> Leather Helmet
# WEAPON_LEFT  -> Bronze Sword
#
var _equipped: Dictionary = {}


# =========================================================
# CONSULTAS
# =========================================================

func get_item(
	slot: Slot
) -> ItemInstance:
	var item = _equipped.get(
		slot,
		null
	)

	if item is ItemInstance:
		return item as ItemInstance

	return null


func is_slot_empty(
	slot: Slot
) -> bool:
	return get_item(slot) == null


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
) -> int:
	if item == null:
		return -1

	for key in _equipped.keys():
		if _equipped[key] == item:
			return int(key)

	return -1


# =========================================================
# TIPO ACEPTADO POR CADA SLOT
# =========================================================

func get_required_equipment_type(
	slot: Slot
) -> ItemDefinition.EquipmentType:
	match slot:

		Slot.HEAD:
			return ItemDefinition.EquipmentType.HEAD

		Slot.CHEST:
			return ItemDefinition.EquipmentType.CHEST

		Slot.PANTS:
			return ItemDefinition.EquipmentType.PANTS

		Slot.GLOVES:
			return ItemDefinition.EquipmentType.GLOVES

		Slot.BOOTS:
			return ItemDefinition.EquipmentType.BOOTS

		Slot.WEAPON_LEFT, \
		Slot.WEAPON_RIGHT:
			return ItemDefinition.EquipmentType.WEAPON

		Slot.WINGS:
			return ItemDefinition.EquipmentType.WINGS

		Slot.PENDANT:
			return ItemDefinition.EquipmentType.PENDANT

		Slot.RING_LEFT, \
		Slot.RING_RIGHT:
			return ItemDefinition.EquipmentType.RING


	return ItemDefinition.EquipmentType.NONE


# =========================================================
# VALIDACIÓN
# =========================================================

func can_equip(
	slot: Slot,
	item: ItemInstance
) -> bool:
	if (
		item == null
		or
		not item.is_valid()
	):
		return false


	if not is_slot_empty(slot):
		return false


	var definition := item.definition


	if not definition.is_equipment():
		return false


	var required_type := (
		get_required_equipment_type(
			slot
		)
	)


	return (
		definition.equipment_type
		==
		required_type
	)


# =========================================================
# EQUIPAR
# =========================================================

func equip_item(
	slot: Slot,
	item: ItemInstance
) -> bool:
	if not can_equip(
		slot,
		item
	):
		return false


	_equipped[slot] = item


	item_equipped.emit(
		slot,
		item
	)


	return true


# =========================================================
# DESEQUIPAR
# =========================================================

func unequip_item(
	slot: Slot
) -> ItemInstance:
	var item := get_item(
		slot
	)


	if item == null:
		return null


	_equipped.erase(
		slot
	)


	item_unequipped.emit(
		slot,
		item
	)


	return item


# =========================================================
# INVENTARIO -> EQUIPAMIENTO
# =========================================================

func equip_from_inventory(
	source_inventory: InventoryData,
	item: ItemInstance,
	slot: Slot
) -> bool:
	if source_inventory == null:
		return false


	if item == null:
		return false


	# El item debe pertenecer al inventario origen.
	if not source_inventory.items.has(
		item
	):
		return false


	# Primero validamos TODO antes de modificar nada.
	if not can_equip(
		slot,
		item
	):
		return false


	var old_position := (
		item.grid_position
	)


	# -----------------------------------------------------
	# Lo quitamos del inventario.
	# -----------------------------------------------------

	if not source_inventory.remove_item(
		item
	):
		return false


	# -----------------------------------------------------
	# Lo equipamos.
	# -----------------------------------------------------

	if equip_item(
		slot,
		item
	):
		return true


	# -----------------------------------------------------
	# Seguridad:
	#
	# Si por algún motivo extraordinario fallara el equip
	# después de quitarlo del inventario, intentamos
	# restaurarlo.
	# -----------------------------------------------------

	item.grid_position = old_position

	source_inventory.add_item(
		item
	)


	return false

# =========================================================
# EQUIPAMIENTO -> INVENTARIO
# =========================================================

func unequip_to_inventory(
	target_inventory: InventoryData,
	slot: Slot,
	new_position: Vector2i
) -> bool:
	if target_inventory == null:
		return false


	var item := get_item(
		slot
	)


	if item == null:
		return false


	# -----------------------------------------------------
	# ANTES de modificar nada comprobamos que el item
	# entre en el inventario destino.
	# -----------------------------------------------------

	if not target_inventory.can_place_item(
		item,
		new_position
	):
		return false


	var old_position := (
		item.grid_position
	)


	# -----------------------------------------------------
	# Quitamos lógicamente del equipamiento.
	#
	# No llamamos todavía a unequip_item() porque queremos
	# que la operación sea lo más atómica posible.
	# -----------------------------------------------------

	_equipped.erase(
		slot
	)


	# -----------------------------------------------------
	# Nueva posición dentro del inventario.
	# -----------------------------------------------------

	item.grid_position = (
		new_position
	)


	# -----------------------------------------------------
	# Intentamos agregarlo al inventario.
	# -----------------------------------------------------

	if not target_inventory.add_item(
		item
	):
		# -------------------------------------------------
		# ROLLBACK
		#
		# Si algo fallara inesperadamente, restauramos
		# el estado anterior.
		# -------------------------------------------------

		item.grid_position = (
			old_position
		)

		_equipped[slot] = item

		return false


	# -----------------------------------------------------
	# Ahora sí avisamos que dejó el equipamiento.
	#
	# InventoryData.add_item() ya emitió item_added,
	# por lo que InventoryGrid creará automáticamente
	# su InventoryItemView.
	# -----------------------------------------------------

	item_unequipped.emit(
		slot,
		item
	)


	return true
	
# =========================================================
# BUSCAR SLOT COMPATIBLE AUTOMÁTICAMENTE
# =========================================================

func find_first_compatible_empty_slot(
	item: ItemInstance
) -> int:
	if (
		item == null
		or
		not item.is_valid()
	):
		return -1


	# -----------------------------------------------------
	# Prioridad automática.
	#
	# Para WEAPON:
	# LEFT primero, luego RIGHT.
	#
	# Para RING:
	# LEFT primero, luego RIGHT.
	#
	# Más adelante podemos cambiar esta prioridad.
	# -----------------------------------------------------

	var priority := [
		Slot.HEAD,
		Slot.CHEST,
		Slot.PANTS,
		Slot.GLOVES,
		Slot.BOOTS,

		Slot.WEAPON_LEFT,
		Slot.WEAPON_RIGHT,

		Slot.WINGS,
		Slot.PENDANT,

		Slot.RING_LEFT,
		Slot.RING_RIGHT
	]


	for slot in priority:
		if can_equip(
			slot,
			item
		):
			return slot


	return -1
