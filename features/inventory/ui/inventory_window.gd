@tool
class_name InventoryWindow
extends BaseWindow


# =========================================================
# REFERENCIAS
# =========================================================

@onready var equipment_panel: EquipmentPanel = (
	$ContentMargin/Content/Body/InventoryContent/EquipmentPanel
)


@onready var inventory_grid: InventoryGrid = (
	$ContentMargin/Content/Body/InventoryContent/BagPanel/BagMargin/GridCenter/InventoryGrid
)

@onready var sort_button: Button = (
	$ContentMargin/Content/Body/InventoryContent/Footer/SortButton
)


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	super._ready()
	
	if Engine.is_editor_hint():
		return

	# =====================================================
	# INVENTARIO - DOBLE CLIC
	# =====================================================

	if not inventory_grid.item_activated.is_connected(
		_on_inventory_item_activated
	):
		inventory_grid.item_activated.connect(
			_on_inventory_item_activated
		)


	# =====================================================
	# EQUIPAMIENTO - DOBLE CLIC
	# =====================================================

	if not equipment_panel.item_activated.is_connected(
		_on_equipment_item_activated
	):
		equipment_panel.item_activated.connect(
			_on_equipment_item_activated
		)


	# =====================================================
	# BOTÓN ORDENAR
	# =====================================================

	if not sort_button.pressed.is_connected(
		_on_sort_button_pressed
	):
		sort_button.pressed.connect(
			_on_sort_button_pressed
		)


	print(
		"InventoryWindow READY | SortButton conectado: ",
		sort_button.pressed.is_connected(
			_on_sort_button_pressed
		)
	)


# =========================================================
# DOBLE CLIC INVENTARIO -> EQUIPAMIENTO
# =========================================================

func _on_inventory_item_activated(
	item: ItemInstance
) -> void:
	if item == null:
		return


	if inventory_grid.inventory_data == null:
		return


	if equipment_panel.equipment_data == null:
		return


	var slot := (
		equipment_panel.equipment_data
		.find_first_compatible_empty_slot(
			item
		)
	)


	# -----------------------------------------------------
	# No existe ningún slot válido/libre.
	# -----------------------------------------------------

	if slot < 0:
		print(
			"No hay un slot compatible libre para ",
			item.definition.display_name
		)

		return


	var success := (
		equipment_panel.equipment_data
		.equip_from_inventory(
			inventory_grid.inventory_data,
			item,
			slot
		)
	)


	if not success:
		print(
			"No se pudo equipar automáticamente ",
			item.definition.display_name
		)


# =========================================================
# DOBLE CLIC EQUIPAMIENTO -> INVENTARIO
# =========================================================

func _on_equipment_item_activated(
	slot: EquipmentData.Slot,
	item: ItemInstance
) -> void:
	if item == null:
		return


	if inventory_grid.inventory_data == null:
		return


	if equipment_panel.equipment_data == null:
		return


	# -----------------------------------------------------
	# Buscamos automáticamente un hueco donde ENTRE
	# el item completo.
	# -----------------------------------------------------

	var free_position := (
		inventory_grid.inventory_data
		.find_first_free_position(
			item
		)
	)


	if free_position.x < 0:
		print(
			"No hay espacio suficiente para desequipar ",
			item.definition.display_name
		)

		return


	var success := (
		equipment_panel.equipment_data
		.unequip_to_inventory(
			inventory_grid.inventory_data,
			slot,
			free_position
		)
	)


	if not success:
		print(
			"No se pudo desequipar automáticamente ",
			item.definition.display_name
		)

# =========================================================
# ORDENAR INVENTARIO
# =========================================================

func _on_sort_button_pressed() -> void:
	if inventory_grid.inventory_data == null:
		return


	var success := (
		inventory_grid.inventory_data
		.sort_items()
	)


	if not success:
		print(
			"No se pudo ordenar el inventario."
		)
