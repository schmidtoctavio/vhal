class_name InventoryData
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

signal item_added(item: ItemInstance)

signal item_removed(item: ItemInstance)

signal item_moved(
	item: ItemInstance,
	old_position: Vector2i,
	new_position: Vector2i
)

signal item_quantity_changed(
	item: ItemInstance,
	old_quantity: int,
	new_quantity: int
)


# =========================================================
# CONFIGURACIÓN
# =========================================================

var columns: int = 8
var rows: int = 8


# =========================================================
# ITEMS
# =========================================================

var items: Array[ItemInstance] = []


# =========================================================
# MATRIZ DE OCUPACIÓN
# =========================================================

# _occupancy[y][x]
#
# null
#     = libre
#
# ItemInstance
#     = ocupada por ese item
#
var _occupancy: Array = []


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	new_columns: int = 8,
	new_rows: int = 8
) -> void:
	columns = maxi(
		new_columns,
		1
	)

	rows = maxi(
		new_rows,
		1
	)

	_build_occupancy()


# =========================================================
# CONSTRUIR MATRIZ
# =========================================================

func _build_occupancy() -> void:
	_occupancy.clear()

	for y in range(rows):
		var row: Array = []

		for x in range(columns):
			row.append(null)

		_occupancy.append(row)


# =========================================================
# LÍMITES
# =========================================================

func is_cell_inside(
	cell: Vector2i
) -> bool:
	return (
		cell.x >= 0
		and
		cell.y >= 0
		and
		cell.x < columns
		and
		cell.y < rows
	)


func is_area_inside(
	origin: Vector2i,
	area_size: Vector2i
) -> bool:
	return (
		origin.x >= 0
		and
		origin.y >= 0
		and
		origin.x + area_size.x <= columns
		and
		origin.y + area_size.y <= rows
	)


# =========================================================
# CONSULTAR UNA CELDA
# =========================================================

func get_item_at(
	cell: Vector2i
) -> ItemInstance:
	if not is_cell_inside(cell):
		return null

	var occupant = _occupancy[cell.y][cell.x]

	if occupant is ItemInstance:
		return occupant as ItemInstance

	return null


func is_cell_free(
	cell: Vector2i
) -> bool:
	return get_item_at(cell) == null


# =========================================================
# VALIDAR POSICIÓN
# =========================================================

func can_place_item(
	item: ItemInstance,
	origin: Vector2i,
	ignore_item: ItemInstance = null
) -> bool:
	if (
		item == null
		or
		not item.is_valid()
	):
		return false


	var item_size := item.get_grid_size()


	# -----------------------------------------------------
	# Primero comprobamos límites.
	# -----------------------------------------------------

	if not is_area_inside(
		origin,
		item_size
	):
		return false


	# -----------------------------------------------------
	# Después ocupación.
	# -----------------------------------------------------

	for y in range(item_size.y):
		for x in range(item_size.x):
			var cell := Vector2i(
				origin.x + x,
				origin.y + y
			)


			var occupant = (
				_occupancy[cell.y][cell.x]
			)


			if (
				occupant != null
				and
				occupant != ignore_item
			):
				return false


	return true


# =========================================================
# OCUPAR
# =========================================================

func _occupy_area(
	item: ItemInstance,
	origin: Vector2i
) -> void:
	var item_size := item.get_grid_size()


	for y in range(item_size.y):
		for x in range(item_size.x):
			var cell := Vector2i(
				origin.x + x,
				origin.y + y
			)

			_occupancy[cell.y][cell.x] = item


# =========================================================
# LIBERAR
# =========================================================

func _free_area(
	item: ItemInstance,
	origin: Vector2i
) -> void:
	var item_size := item.get_grid_size()


	for y in range(item_size.y):
		for x in range(item_size.x):
			var cell := Vector2i(
				origin.x + x,
				origin.y + y
			)


			if not is_cell_inside(cell):
				continue


			if (
				_occupancy[cell.y][cell.x]
				== item
			):
				_occupancy[cell.y][cell.x] = null


# =========================================================
# AGREGAR ITEM EXISTENTE
# =========================================================

func add_item(
	item: ItemInstance
) -> bool:
	if (
		item == null
		or
		not item.is_valid()
	):
		return false


	if items.has(item):
		return false


	if not can_place_item(
		item,
		item.grid_position
	):
		return false


	items.append(item)


	_occupy_area(
		item,
		item.grid_position
	)


	item_added.emit(item)

	return true


# =========================================================
# CREAR + AGREGAR ITEM
# =========================================================

func create_item(
	definition: ItemDefinition,
	quantity: int,
	position: Vector2i,
	uid: String = ""
) -> ItemInstance:
	if definition == null:
		return null


	var item := ItemInstance.new(
		definition,
		quantity,
		position,
		uid
	)


	if not add_item(item):
		return null


	return item


# =========================================================
# QUITAR ITEM
# =========================================================

func remove_item(
	item: ItemInstance
) -> bool:
	if item == null:
		return false


	if not items.has(item):
		return false


	_free_area(
		item,
		item.grid_position
	)


	items.erase(item)


	item_removed.emit(item)

	return true


# =========================================================
# MOVER ITEM
# =========================================================

func move_item(
	item: ItemInstance,
	new_position: Vector2i
) -> bool:
	if item == null:
		return false


	if not items.has(item):
		return false


	if item.grid_position == new_position:
		return true


	if not can_place_item(
		item,
		new_position,
		item
	):
		return false


	var old_position := item.grid_position


	_free_area(
		item,
		old_position
	)


	item.grid_position = new_position


	_occupy_area(
		item,
		new_position
	)


	item_moved.emit(
		item,
		old_position,
		new_position
	)


	return true

# =========================================================
# TRANSFERIR ITEM A OTRO INVENTARIO
# =========================================================

func transfer_item_to(
	target_inventory: InventoryData,
	item: ItemInstance,
	new_position: Vector2i
) -> bool:
	if target_inventory == null:
		return false

	if item == null:
		return false

	if not items.has(item):
		return false


	# -----------------------------------------------------
	# Si origen y destino son el mismo inventario,
	# simplemente lo movemos.
	# -----------------------------------------------------

	if target_inventory == self:
		return move_item(
			item,
			new_position
		)


	# -----------------------------------------------------
	# No debería existir ya en el inventario destino.
	# -----------------------------------------------------

	if target_inventory.items.has(item):
		return false


	# -----------------------------------------------------
	# Antes de tocar nada comprobamos que el destino
	# pueda recibirlo.
	# -----------------------------------------------------

	if not target_inventory.can_place_item(
		item,
		new_position
	):
		return false


	var old_position := item.grid_position


	# -----------------------------------------------------
	# Quitamos del inventario origen.
	# -----------------------------------------------------

	_free_area(
		item,
		old_position
	)

	items.erase(item)


	# -----------------------------------------------------
	# Cambiamos la posición lógica.
	# -----------------------------------------------------

	item.grid_position = new_position


	# -----------------------------------------------------
	# Agregamos al destino.
	# -----------------------------------------------------

	target_inventory.items.append(
		item
	)

	target_inventory._occupy_area(
		item,
		new_position
	)


	# -----------------------------------------------------
	# Avisamos a ambas representaciones.
	#
	# El origen quitará su View.
	# El destino creará otra View del MISMO ItemInstance.
	# -----------------------------------------------------

	item_removed.emit(
		item
	)

	target_inventory.item_added.emit(
		item
	)


	return true

# =========================================================
# STACK ENTRE ITEMS
# =========================================================

func merge_stack_from(
	source_inventory: InventoryData,
	source_item: ItemInstance,
	target_item: ItemInstance
) -> int:
	if source_inventory == null:
		return 0


	if source_item == null:
		return 0


	if target_item == null:
		return 0


	if source_item == target_item:
		return 0


	# -----------------------------------------------------
	# Source debe existir en su inventario.
	# -----------------------------------------------------

	if not source_inventory.items.has(
		source_item
	):
		return 0


	# -----------------------------------------------------
	# Target debe existir en ESTE inventario.
	# -----------------------------------------------------

	if not items.has(
		target_item
	):
		return 0


	# -----------------------------------------------------
	# Deben ser compatibles.
	# -----------------------------------------------------

	if not target_item.can_stack_with(
		source_item
	):
		return 0


	var available_space := (
		target_item.get_remaining_stack_space()
	)


	if available_space <= 0:
		return 0


	# -----------------------------------------------------
	# ¿Cuánto podemos mover?
	# -----------------------------------------------------

	var amount_to_move := mini(
		source_item.quantity,
		available_space
	)


	if amount_to_move <= 0:
		return 0


	# =====================================================
	# TARGET
	# =====================================================

	var old_target_quantity := (
		target_item.quantity
	)


	target_item.quantity += (
		amount_to_move
	)


	item_quantity_changed.emit(
		target_item,
		old_target_quantity,
		target_item.quantity
	)


	# =====================================================
	# SOURCE
	# =====================================================

	var old_source_quantity := (
		source_item.quantity
	)


	source_item.quantity -= (
		amount_to_move
	)


	# -----------------------------------------------------
	# Si source quedó vacío:
	#
	# se elimina la instancia del inventario.
	# -----------------------------------------------------

	if source_item.quantity <= 0:
		source_inventory.remove_item(
			source_item
		)

	else:
		# -------------------------------------------------
		# Todavía quedan unidades.
		# -------------------------------------------------

		source_inventory.item_quantity_changed.emit(
			source_item,
			old_source_quantity,
			source_item.quantity
		)


	return amount_to_move
	
	# =========================================================
# BUSCAR PRIMER ESPACIO LIBRE
# =========================================================

func find_first_free_position(
	item: ItemInstance,
	ignore_item: ItemInstance = null
) -> Vector2i:
	if (
		item == null
		or
		not item.is_valid()
	):
		return Vector2i(-1, -1)


	for y in range(rows):
		for x in range(columns):
			var position := Vector2i(
				x,
				y
			)


			if can_place_item(
				item,
				position,
				ignore_item
			):
				return position


	return Vector2i(-1, -1)

# =========================================================
# AGREGAR ITEM AUTOMÁTICAMENTE
# =========================================================

func add_item_auto(
	item: ItemInstance
) -> bool:
	if (
		item == null
		or
		not item.is_valid()
	):
		return false


	if items.has(item):
		return false


	var free_position := (
		find_first_free_position(
			item
		)
	)


	if free_position.x < 0:
		return false


	item.grid_position = (
		free_position
	)


	return add_item(
		item
	)

# =========================================================
# CREAR ITEM AUTOMÁTICAMENTE
# =========================================================

func create_item_auto(
	definition: ItemDefinition,
	quantity: int = 1,
	uid: String = ""
) -> ItemInstance:
	if definition == null:
		return null


	var item := ItemInstance.new(
		definition,
		quantity,
		Vector2i.ZERO,
		uid
	)


	if not add_item_auto(
		item
	):
		return null


	return item

# =========================================================
# COMPARADOR PARA ORDENAR
# =========================================================

func _sort_items_for_packing(
	a: ItemInstance,
	b: ItemInstance
) -> bool:
	var size_a := a.get_grid_size()
	var size_b := b.get_grid_size()


	var area_a := (
		size_a.x
		*
		size_a.y
	)

	var area_b := (
		size_b.x
		*
		size_b.y
	)


	# -----------------------------------------------------
	# Primero items con mayor área.
	#
	# Ejemplo:
	#
	# armor 2x3 antes que potion 1x1
	# -----------------------------------------------------

	if area_a != area_b:
		return area_a > area_b


	# -----------------------------------------------------
	# Si tienen misma área:
	# priorizamos mayor altura.
	# -----------------------------------------------------

	if size_a.y != size_b.y:
		return size_a.y > size_b.y


	# -----------------------------------------------------
	# Después mayor anchura.
	# -----------------------------------------------------

	if size_a.x != size_b.x:
		return size_a.x > size_b.x


	# -----------------------------------------------------
	# Finalmente usamos el ID para conseguir
	# un resultado estable.
	# -----------------------------------------------------

	return (
		String(a.definition.item_id)
		<
		String(b.definition.item_id)
	)

# =========================================================
# ORDENAR / COMPACTAR INVENTARIO
# =========================================================

func sort_items() -> bool:
	if items.is_empty():
		return true


	# =====================================================
	# 1. GUARDAMOS ESTADO ACTUAL
	# =====================================================

	var old_positions: Dictionary = {}


	for item in items:
		old_positions[
			item.get_instance_id()
		] = item.grid_position


	# =====================================================
	# 2. HACEMOS UNA COPIA PARA DECIDIR EL ORDEN
	# =====================================================

	var sorted_items: Array[ItemInstance] = (
		items.duplicate()
	)


	sorted_items.sort_custom(
		_sort_items_for_packing
	)


	# =====================================================
	# 3. VACIAMOS LA OCUPACIÓN
	#
	# Los ItemInstance siguen existiendo.
	# Sólo estamos reconstruyendo dónde están.
	# =====================================================

	_build_occupancy()


	# =====================================================
	# 4. INTENTAMOS REINSERTAR TODO
	# =====================================================

	for item in sorted_items:
		var free_position := (
			find_first_free_position(
				item
			)
		)


		# -------------------------------------------------
		# En teoría esto no debería pasar si el inventario
		# ya era válido.
		#
		# Pero hacemos rollback por seguridad.
		# -------------------------------------------------

		if free_position.x < 0:
			_restore_positions(
				old_positions
			)

			return false


		item.grid_position = (
			free_position
		)


		_occupy_area(
			item,
			free_position
		)


	# =====================================================
	# 5. ACTUALIZAMOS EL ORDEN DEL ARRAY
	# =====================================================

	items = sorted_items


	# =====================================================
	# 6. EMITIMOS MOVIMIENTOS
	# =====================================================

	for item in items:
		var old_position: Vector2i = (
			old_positions.get(
				item.get_instance_id(),
				item.grid_position
			)
		)


		if (
			old_position
			==
			item.grid_position
		):
			continue


		item_moved.emit(
			item,
			old_position,
			item.grid_position
		)


	return true

# =========================================================
# RESTAURAR POSICIONES
# =========================================================

func _restore_positions(
	old_positions: Dictionary
) -> void:
	_build_occupancy()


	for item in items:
		var key := (
			item.get_instance_id()
		)


		if not old_positions.has(
			key
		):
			continue


		var old_position: Vector2i = (
			old_positions[key]
		)


		item.grid_position = (
			old_position
		)


		_occupy_area(
			item,
			old_position
		)
