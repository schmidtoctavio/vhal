class_name InventoryGrid
extends Control

signal item_activated(
	item: ItemInstance
)

# =========================================================
# ESCENAS
# =========================================================

const CELL_SCENE := preload(
	"res://features/inventory/ui/inventory_cell.tscn"
)

const ITEM_VIEW_SCENE := preload(
	"res://features/inventory/ui/inventory_item_view.tscn"
)


# =========================================================
# CONFIGURACIÓN VISUAL
# =========================================================

@export_group("Grid")

@export_range(1, 16, 1)
var columns: int = 8

@export_range(1, 16, 1)
var rows: int = 8

@export_range(16, 128, 1)
var cell_size: int = 40

@export_range(0, 32, 1)
var cell_gap: int = 8


@export_group("Drag & Drop")

@export var valid_drop_color := Color(
	0.20,
	1.00,
	0.20,
	0.32
)

@export var invalid_drop_color := Color(
	1.00,
	0.20,
	0.20,
	0.32
)


# =========================================================
# REFERENCIAS VISUALES
# =========================================================

@onready var cells_layer: GridContainer = \
	$CellsLayer

@onready var drop_preview: ColorRect = \
	$DropPreview

@onready var items_layer: Control = \
	$ItemsLayer


# =========================================================
# MODELO
# =========================================================

# Esta es ahora la FUENTE DE VERDAD.
#
# InventoryGrid no guarda ocupación ni posiciones.
#
var inventory_data: InventoryData = null


# =========================================================
# RELACIÓN ITEMINSTANCE -> VIEW
# =========================================================

var _views_by_instance_id: Dictionary = {}


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


	cells_layer.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	drop_preview.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	items_layer.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


	_hide_drop_preview()


	# -----------------------------------------------------
	# InventoryGrid ya NO crea InventoryData.
	#
	# El modelo debe ser entregado externamente.
	# -----------------------------------------------------

	if inventory_data != null:
		_activate_inventory_data()
	else:
		_build_cells()


func _notification(
	what: int
) -> void:
	if what == NOTIFICATION_DRAG_END:
		if is_instance_valid(
			drop_preview
		):
			_hide_drop_preview()


func _exit_tree() -> void:
	_disconnect_inventory_data()


# =========================================================
# ASIGNAR INVENTORY DATA
# =========================================================

func bind_inventory_data(
	data: InventoryData
) -> void:
	# -----------------------------------------------------
	# Puede llamarse antes de que InventoryGrid haya
	# entrado al SceneTree.
	# -----------------------------------------------------

	if not is_node_ready():
		inventory_data = data
		return


	if inventory_data == data:
		return


	_disconnect_inventory_data()

	_clear_item_views()


	inventory_data = data


	if inventory_data == null:
		return


	_activate_inventory_data()


# =========================================================
# ACTIVAR MODELO
# =========================================================

func _activate_inventory_data() -> void:
	if inventory_data == null:
		return


	# -----------------------------------------------------
	# La dimensión lógica manda.
	#
	# Si InventoryData dice 8×8, la UI muestra 8×8.
	# -----------------------------------------------------

	columns = inventory_data.columns
	rows = inventory_data.rows


	_build_cells()

	_connect_inventory_data()

	_rebuild_item_views()


# =========================================================
# SIGNALS DEL MODELO
# =========================================================

func _connect_inventory_data() -> void:
	if inventory_data == null:
		return


	if not inventory_data.item_added.is_connected(
		_on_item_added
	):
		inventory_data.item_added.connect(
			_on_item_added
		)


	if not inventory_data.item_removed.is_connected(
		_on_item_removed
	):
		inventory_data.item_removed.connect(
			_on_item_removed
		)


	if not inventory_data.item_moved.is_connected(
		_on_item_moved
	):
		inventory_data.item_moved.connect(
			_on_item_moved
		)
	
	if not inventory_data.item_quantity_changed.is_connected(
		_on_item_quantity_changed
	):
		inventory_data.item_quantity_changed.connect(
			_on_item_quantity_changed
		)


func _disconnect_inventory_data() -> void:
	if inventory_data == null:
		return


	if inventory_data.item_added.is_connected(
		_on_item_added
	):
		inventory_data.item_added.disconnect(
			_on_item_added
		)


	if inventory_data.item_removed.is_connected(
		_on_item_removed
	):
		inventory_data.item_removed.disconnect(
			_on_item_removed
		)


	if inventory_data.item_moved.is_connected(
		_on_item_moved
	):
		inventory_data.item_moved.disconnect(
			_on_item_moved
		)
	
	if inventory_data.item_quantity_changed.is_connected(
		_on_item_quantity_changed
	):
		inventory_data.item_quantity_changed.disconnect(
			_on_item_quantity_changed
		)


# =========================================================
# EVENTOS DEL MODELO
# =========================================================

func _on_item_added(
	item: ItemInstance
) -> void:
	_create_view_for_item(
		item
	)


func _on_item_removed(
	item: ItemInstance
) -> void:
	var view := _get_view(
		item
	)


	_unregister_view(
		item
	)


	if (
		view != null
		and
		is_instance_valid(view)
	):
		view.queue_free()


func _on_item_moved(
	item: ItemInstance,
	_old_position: Vector2i,
	_new_position: Vector2i
) -> void:
	var view := _get_view(
		item
	)


	if view != null:
		view.sync_from_instance()

func _on_item_quantity_changed(
	item: ItemInstance,
	_old_quantity: int,
	_new_quantity: int
) -> void:
	var view := _get_view(
		item
	)


	if view != null:
		view.sync_from_instance()

# =========================================================
# CONSTRUIR CELDAS VISUALES
# =========================================================

func _build_cells() -> void:
	_clear_cells()


	cells_layer.columns = columns
	
	cells_layer.add_theme_constant_override(
		"h_separation",
		cell_gap
	)


	cells_layer.add_theme_constant_override(
		"v_separation",
		cell_gap
	)


	for y in range(rows):
		for x in range(columns):
			var cell := (
				CELL_SCENE.instantiate()
			)


			cell.custom_minimum_size = Vector2(
				cell_size,
				cell_size
			)


			cell.mouse_filter = \
				Control.MOUSE_FILTER_IGNORE


			cells_layer.add_child(
				cell
			)


	_update_grid_size()


func _clear_cells() -> void:
	for child in cells_layer.get_children():
		child.queue_free()


func _update_grid_size() -> void:
	var grid_size := Vector2(
		columns * cell_size
		+
		maxi(
			columns - 1,
			0
		) * cell_gap,

		rows * cell_size
		+
		maxi(
			rows - 1,
			0
		) * cell_gap
	)


	custom_minimum_size = grid_size

	size = grid_size


	cells_layer.position = (
		Vector2.ZERO
	)

	cells_layer.size = (
		grid_size
	)


	items_layer.position = (
		Vector2.ZERO
	)

# =========================================================
# COORDENADAS
# =========================================================

func cell_to_local(
	cell: Vector2i
) -> Vector2:
	var pitch := get_cell_pitch()


	return Vector2(
		cell.x * pitch,
		cell.y * pitch
	)


func local_to_cell(
	local_position: Vector2
) -> Vector2i:
	var pitch := get_cell_pitch()


	return Vector2i(
		floori(
			local_position.x / pitch
		),
		floori(
			local_position.y / pitch
		)
	)

func get_cell_pitch() -> int:
	return (
		cell_size
		+
		cell_gap
	)


func get_area_pixel_size(
	area_size: Vector2i
) -> Vector2:
	if (
		area_size.x <= 0
		or
		area_size.y <= 0
	):
		return Vector2.ZERO


	return Vector2(
		area_size.x * cell_size
		+
		maxi(
			area_size.x - 1,
			0
		) * cell_gap,

		area_size.y * cell_size
		+
		maxi(
			area_size.y - 1,
			0
		) * cell_gap
	)

# =========================================================
# VIEWS
# =========================================================

func _get_view(
	item: ItemInstance
) -> InventoryItemView:
	if item == null:
		return null


	var key := item.get_instance_id()


	var candidate = _views_by_instance_id.get(
		key,
		null
	)


	if (
		candidate is InventoryItemView
		and
		is_instance_valid(candidate)
	):
		return candidate as InventoryItemView


	_views_by_instance_id.erase(
		key
	)


	return null


func _register_view(
	item: ItemInstance,
	view: InventoryItemView
) -> void:
	if item == null:
		return


	if view == null:
		return


	_views_by_instance_id[
		item.get_instance_id()
	] = view


func _unregister_view(
	item: ItemInstance
) -> void:
	if item == null:
		return


	_views_by_instance_id.erase(
		item.get_instance_id()
	)


func _clear_item_views() -> void:
	for child in items_layer.get_children():
		child.queue_free()


	_views_by_instance_id.clear()


func _rebuild_item_views() -> void:
	_clear_item_views()


	if inventory_data == null:
		return


	for item in inventory_data.items:
		_create_view_for_item(
			item
		)


func _create_view_for_item(
	item: ItemInstance
) -> InventoryItemView:
	if (
		item == null
		or
		not item.is_valid()
	):
		return null


	# -----------------------------------------------------
	# Evitamos duplicar una View para la misma instancia.
	# -----------------------------------------------------

	var existing := _get_view(
		item
	)


	if existing != null:
		return existing


	var view := (
		ITEM_VIEW_SCENE.instantiate()
		as InventoryItemView
	)


	if view == null:
		return null


	items_layer.add_child(
		view
	)


	view.setup(
		item,
		cell_size,
		cell_gap,
		self
	)
	
	if not view.item_activated.is_connected(
		_on_view_item_activated
	):
		view.item_activated.connect(
			_on_view_item_activated
		)


	view.position = cell_to_local(
		item.grid_position
	)


	_register_view(
		item,
		view
	)


	return view

func _on_view_item_activated(
	item: ItemInstance
) -> void:
	item_activated.emit(
		item
	)


# =========================================================
# DRAG PREVIEW
# =========================================================

func create_drag_preview(
	source_view: InventoryItemView,
	grab_position: Vector2
) -> Control:
	if source_view == null:
		return null


	if source_view.item_instance == null:
		return null


	var preview := (
		ITEM_VIEW_SCENE.instantiate()
		as InventoryItemView
	)


	if preview == null:
		return null


	preview.setup(
		source_view.item_instance,
		cell_size,
		cell_gap,
		null
	)


	preview.mouse_filter = \
		Control.MOUSE_FILTER_IGNORE


	preview.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.80
	)


	preview.position = (
		-grab_position
	)


	return preview


# =========================================================
# VALIDAR DRAG DATA
# =========================================================

func _is_inventory_drag_data(
	data: Variant
) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false


	var dictionary := (
		data as Dictionary
	)


	if (
		dictionary.get(
			"kind",
			&""
		)
		!= &"inventory_item"
	):
		return false


	if not dictionary.has(
		"item"
	):
		return false


	if not dictionary.has(
		"source_grid"
	):
		return false


	var item = dictionary["item"]

	var source_grid = dictionary[
		"source_grid"
	]


	if not (
		item is ItemInstance
	):
		return false


	if not (
		source_grid is InventoryGrid
	):
		return false


	if not is_instance_valid(
		source_grid
	):
		return false


	return true

func _is_equipment_drag_data(
	data: Variant
) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false


	var dictionary := (
		data as Dictionary
	)


	if (
		dictionary.get(
			"kind",
			&""
		)
		!= &"equipment_item"
	):
		return false


	if not dictionary.has(
		"item"
	):
		return false


	if not dictionary.has(
		"source_equipment_data"
	):
		return false


	if not dictionary.has(
		"source_slot"
	):
		return false


	if not (
		dictionary["item"]
		is ItemInstance
	):
		return false


	if not (
		dictionary["source_equipment_data"]
		is EquipmentData
	):
		return false


	return true

func _get_drop_origin(
	at_position: Vector2,
	data: Dictionary
) -> Vector2i:
	var grab_cell_offset: Vector2i = (
		data.get(
			"grab_cell_offset",
			Vector2i.ZERO
		)
	)


	return (
		local_to_cell(
			at_position
		)
		-
		grab_cell_offset
	)


# =========================================================
# DROP PREVIEW
# =========================================================

func _show_drop_preview(
	item: ItemInstance,
	origin: Vector2i,
	is_valid: bool
) -> void:
	if (
		item == null
		or
		not item.is_valid()
	):
		_hide_drop_preview()
		return


	var item_size := (
		item.get_grid_size()
	)


	drop_preview.position = (
		cell_to_local(
			origin
		)
	)


	drop_preview.size = (
		get_area_pixel_size(
			item_size
		)
	)


	if is_valid:
		drop_preview.color = (
			valid_drop_color
		)
	else:
		drop_preview.color = (
			invalid_drop_color
		)


	drop_preview.visible = true


func _hide_drop_preview() -> void:
	drop_preview.visible = false


# =========================================================
# VALIDAR DROP
# =========================================================

func can_drop_data_at(
	at_position: Vector2,
	data: Variant
) -> bool:
	if inventory_data == null:
		_hide_drop_preview()
		return false


	# =====================================================
	# EQUIPMENT -> INVENTORY
	# =====================================================

	if _is_equipment_drag_data(
		data
	):
		var equipment_dictionary := (
			data as Dictionary
		)


		var equipment_item := (
			equipment_dictionary["item"]
			as ItemInstance
		)


		var equipment_origin := _get_drop_origin(
			at_position,
			equipment_dictionary
		)


		var equipment_valid := (
			inventory_data.can_place_item(
				equipment_item,
				equipment_origin
			)
		)


		_show_drop_preview(
			equipment_item,
			equipment_origin,
			equipment_valid
		)


		return equipment_valid


	# =====================================================
	# INVENTORY -> INVENTORY
	# =====================================================

	if not _is_inventory_drag_data(
		data
	):
		_hide_drop_preview()
		return false


	var dictionary := (
		data as Dictionary
	)


	var item := (
		dictionary["item"]
		as ItemInstance
	)


	var source_grid := (
		dictionary["source_grid"]
		as InventoryGrid
	)


	if source_grid.inventory_data == null:
		_hide_drop_preview()
		return false


	# =====================================================
	# CELDA REAL DEBAJO DEL CURSOR
	# =====================================================

	var pointer_cell := local_to_cell(
		at_position
	)


	var target_item: ItemInstance = null


	if inventory_data.is_cell_inside(
		pointer_cell
	):
		target_item = inventory_data.get_item_at(
			pointer_cell
		)


	# =====================================================
	# CASO 1 — STACK
	# =====================================================

	if (
		target_item != null
		and
		target_item != item
		and
		target_item.can_stack_with(item)
		and
		not target_item.is_stack_full()
	):
		_show_drop_preview(
			target_item,
			target_item.grid_position,
			true
		)

		return true


	# =====================================================
	# CASO 2 — MOVIMIENTO NORMAL
	# =====================================================

	var origin := _get_drop_origin(
		at_position,
		dictionary
	)


	var ignore_item: ItemInstance = null


	# Si estamos moviendo dentro del mismo InventoryData,
	# podemos ignorar las celdas ocupadas por nosotros mismos.
	if (
		source_grid.inventory_data
		==
		inventory_data
	):
		ignore_item = item


	var valid := inventory_data.can_place_item(
		item,
		origin,
		ignore_item
	)


	_show_drop_preview(
		item,
		origin,
		valid
	)


	return valid


# =========================================================
# EJECUTAR DROP
# =========================================================

func drop_data_at(
	at_position: Vector2,
	data: Variant
) -> void:
	if inventory_data == null:
		_hide_drop_preview()
		return

	# =====================================================
	# EQUIPMENT -> INVENTORY
	# =====================================================

	if _is_equipment_drag_data(
		data
	):
		var equipment_dictionary := (
			data as Dictionary
		)


		var equipment_item := (
			equipment_dictionary["item"]
			as ItemInstance
		)


		var source_equipment := (
			equipment_dictionary["source_equipment_data"]
			as EquipmentData
		)


		var source_slot = (
			equipment_dictionary["source_slot"]
		)


		var equipment_origin := _get_drop_origin(
			at_position,
			equipment_dictionary
		)


		var equipment_success := (
			source_equipment.unequip_to_inventory(
				inventory_data,
				source_slot,
				equipment_origin
			)
		)


		if not equipment_success:
			print(
				"No se pudo desequipar ",
				equipment_item.definition.display_name,
				" hacia ",
				equipment_origin
			)


		_hide_drop_preview()

		return


	if not _is_inventory_drag_data(
		data
	):
		_hide_drop_preview()
		return


	var dictionary := (
		data as Dictionary
	)


	var item := (
		dictionary["item"]
		as ItemInstance
	)


	var source_grid := (
		dictionary["source_grid"]
		as InventoryGrid
	)


	if source_grid.inventory_data == null:
		_hide_drop_preview()
		return


	# =====================================================
	# CELDA DEBAJO DEL CURSOR
	# =====================================================

	var pointer_cell := local_to_cell(
		at_position
	)


	var target_item: ItemInstance = null


	if inventory_data.is_cell_inside(
		pointer_cell
	):
		target_item = inventory_data.get_item_at(
			pointer_cell
		)


	# =====================================================
	# CASO 1 — STACK
	# =====================================================

	if (
		target_item != null
		and
		target_item != item
		and
		target_item.can_stack_with(item)
		and
		not target_item.is_stack_full()
	):
		var transferred_amount := (
			inventory_data.merge_stack_from(
				source_grid.inventory_data,
				item,
				target_item
			)
		)


		if transferred_amount > 0:
			print(
				"Stack realizado: ",
				transferred_amount,
				" unidades"
			)


			_hide_drop_preview()

			return


	# =====================================================
	# CASO 2 — MOVIMIENTO NORMAL
	# =====================================================

	var origin := _get_drop_origin(
		at_position,
		dictionary
	)


	var success := false


	# -----------------------------------------------------
	# MISMO INVENTARIO
	# -----------------------------------------------------

	if (
		source_grid.inventory_data
		==
		inventory_data
	):
		success = inventory_data.move_item(
			item,
			origin
		)


	# -----------------------------------------------------
	# INVENTARIOS DIFERENTES
	# -----------------------------------------------------

	else:
		success = (
			source_grid.inventory_data
			.transfer_item_to(
				inventory_data,
				item,
				origin
			)
		)


	if not success:
		print(
			"No se pudo mover ",
			item.definition.display_name,
			" a ",
			origin
		)


	_hide_drop_preview()


# =========================================================
# GODOT DRAG & DROP
# =========================================================

func _can_drop_data(
	at_position: Vector2,
	data: Variant
) -> bool:
	return can_drop_data_at(
		at_position,
		data
	)


func _drop_data(
	at_position: Vector2,
	data: Variant
) -> void:
	drop_data_at(
		at_position,
		data
	)
