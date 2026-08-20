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
# SLOT INVÁLIDO
# =========================================================

const INVALID_SLOT: int = -1

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
	var slot_id := (
		get_slot_id(
			slot
		)
	)


	if (
		slot_id
		==
		EquipmentSlotContract.INVALID_SLOT_ID
	):
		return ItemDefinition.EquipmentType.NONE


	return EquipmentSlotContract.get_required_equipment_type(
		String(slot_id)
	)

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

# =========================================================
# RUNTIME SLOT -> STABLE SLOT ID
# =========================================================

static func get_slot_id(
	slot: int
) -> StringName:
	match slot:
		Slot.HEAD:
			return EquipmentSlotContract.HEAD

		Slot.CHEST:
			return EquipmentSlotContract.CHEST

		Slot.PANTS:
			return EquipmentSlotContract.PANTS

		Slot.GLOVES:
			return EquipmentSlotContract.GLOVES

		Slot.BOOTS:
			return EquipmentSlotContract.BOOTS

		Slot.WEAPON_LEFT:
			return EquipmentSlotContract.WEAPON_LEFT

		Slot.WEAPON_RIGHT:
			return EquipmentSlotContract.WEAPON_RIGHT

		Slot.WINGS:
			return EquipmentSlotContract.WINGS

		Slot.PENDANT:
			return EquipmentSlotContract.PENDANT

		Slot.RING_LEFT:
			return EquipmentSlotContract.RING_LEFT

		Slot.RING_RIGHT:
			return EquipmentSlotContract.RING_RIGHT


	return EquipmentSlotContract.INVALID_SLOT_ID


# =========================================================
# STABLE SLOT ID -> RUNTIME SLOT
# =========================================================

static func get_slot_from_id(
	slot_id: String
) -> int:
	var normalized := (
		EquipmentSlotContract.normalize_slot_id(
			slot_id
		)
	)


	match normalized:
		EquipmentSlotContract.HEAD:
			return Slot.HEAD

		EquipmentSlotContract.CHEST:
			return Slot.CHEST

		EquipmentSlotContract.PANTS:
			return Slot.PANTS

		EquipmentSlotContract.GLOVES:
			return Slot.GLOVES

		EquipmentSlotContract.BOOTS:
			return Slot.BOOTS

		EquipmentSlotContract.WEAPON_LEFT:
			return Slot.WEAPON_LEFT

		EquipmentSlotContract.WEAPON_RIGHT:
			return Slot.WEAPON_RIGHT

		EquipmentSlotContract.WINGS:
			return Slot.WINGS

		EquipmentSlotContract.PENDANT:
			return Slot.PENDANT

		EquipmentSlotContract.RING_LEFT:
			return Slot.RING_LEFT

		EquipmentSlotContract.RING_RIGHT:
			return Slot.RING_RIGHT


	return INVALID_SLOT


# =========================================================
# VALIDAR RUNTIME SLOT
# =========================================================

static func is_valid_slot(
	slot: int
) -> bool:
	return (
		get_slot_id(
			slot
		)
		!=
		EquipmentSlotContract.INVALID_SLOT_ID
	)


# =========================================================
# VALIDAR MAPPING COMPLETO
# =========================================================

static func validate_slot_contract_mapping() -> bool:
	if not EquipmentSlotContract.validate_contract():
		return false


	var runtime_slots: Array[int] = [
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
		Slot.RING_RIGHT,
	]


	if (
		runtime_slots.size()
		!=
		EquipmentSlotContract.SLOT_IDS.size()
	):
		return false


	for runtime_slot: int in runtime_slots:
		var slot_id := (
			get_slot_id(
				runtime_slot
			)
		)


		if (
			slot_id
			==
			EquipmentSlotContract.INVALID_SLOT_ID
		):
			return false


		var restored_slot := (
			get_slot_from_id(
				String(slot_id)
			)
		)


		if restored_slot != runtime_slot:
			return false


	return true

# =========================================================
# CONSTRUCTOR
# =========================================================

func _init() -> void:
	assert(
		validate_slot_contract_mapping(),
		(
			"EquipmentData | "
			+
			"Equipment Slot Contract inválido."
		)
	)
