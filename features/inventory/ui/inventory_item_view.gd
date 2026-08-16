class_name InventoryItemView
extends Control

signal item_activated(
	item: ItemInstance
)

const ITEM_TOOLTIP_SCENE := preload(
    "res://features/items/ui/item_tooltip.tscn"
)

# =========================================================
# DATOS
# =========================================================

var item_instance: ItemInstance = null

var inventory_grid: InventoryGrid = null

var _cell_size: int = 40

var _cell_gap: int = 0


# =========================================================
# DRAG
# =========================================================

var _is_dragging_self: bool = false

var _modulate_before_drag: Color = Color.WHITE


# =========================================================
# ACTIVACIÓN POR DOBLE CLIC
# =========================================================

func _gui_input(
	event: InputEvent
) -> void:
	if not (
		event is InputEventMouseButton
	):
		return


	var mouse_event := (
		event as InputEventMouseButton
	)


	if (
		mouse_event.button_index
		!= MOUSE_BUTTON_LEFT
	):
		return


	if not mouse_event.pressed:
		return


	if not mouse_event.double_click:
		return


	if (
		item_instance == null
		or
		not item_instance.is_valid()
	):
		return


	item_activated.emit(
		item_instance
	)


	accept_event()

# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

	tooltip_text = "item"

	_refresh()


func _notification(what: int) -> void:
	if (
		what == NOTIFICATION_DRAG_END
		and
		_is_dragging_self
	):
		self_modulate = _modulate_before_drag

		_is_dragging_self = false


# =========================================================
# SETUP
# =========================================================

func setup(
	instance: ItemInstance,
	new_cell_size: int,
	new_cell_gap: int,
	owner_grid: InventoryGrid
) -> void:
	item_instance = instance

	_cell_size = (
		new_cell_size
	)

	_cell_gap = (
		new_cell_gap
	)

	inventory_grid = (
		owner_grid
	)


	_refresh()

func sync_from_instance() -> void:
	_refresh()

	if (
		item_instance != null
		and
		inventory_grid != null
	):
		position = inventory_grid.cell_to_local(
			item_instance.grid_position
		)


# =========================================================
# VISUAL
# =========================================================

func _refresh() -> void:
	if (
		item_instance == null
		or
		not item_instance.is_valid()
	):
		visible = false
		return


	visible = true


	var definition := item_instance.definition

	var grid_size := item_instance.get_grid_size()


	var visual_size := Vector2(
		grid_size.x * _cell_size
		+
		maxi(
			grid_size.x - 1,
			0
		) * _cell_gap,

		grid_size.y * _cell_size
		+
		maxi(
			grid_size.y - 1,
			0
		) * _cell_gap
	)


	custom_minimum_size = visual_size
	size = visual_size


	# -----------------------------------------------------
	# ICONO
	# -----------------------------------------------------

	var icon_rect := get_node_or_null(
		"IconMargin/ItemIcon"
	) as TextureRect


	if icon_rect:
		icon_rect.texture = definition.icon


	# -----------------------------------------------------
	# CANTIDAD
	# -----------------------------------------------------

	var quantity_label := get_node_or_null(
		"QuantityLabel"
	) as Label


	if quantity_label:
		var show_quantity := (
			item_instance.quantity > 1
		)


		quantity_label.visible = show_quantity


		if show_quantity:
			quantity_label.text = str(
				item_instance.quantity
			)
		else:
			quantity_label.text = ""


# =========================================================
# DRAG SOURCE
# =========================================================

func _get_drag_data(
	at_position: Vector2
) -> Variant:
	if Engine.is_editor_hint():
		return null


	if (
		item_instance == null
		or
		not item_instance.is_valid()
	):
		return null


	if inventory_grid == null:
		return null


	var item_size := item_instance.get_grid_size()


	# -----------------------------------------------------
	# Determinamos desde qué celda interna del item
	# lo agarró el jugador.
	#
	# Una espada 1x3 agarrada por el medio dará:
	#
	# (0, 1)
	# -----------------------------------------------------

	var grab_cell_offset := Vector2i(
		clampi(
			floori(
				at_position.x / _cell_size
			),
			0,
			item_size.x - 1
		),
		clampi(
			floori(
				at_position.y / _cell_size
			),
			0,
			item_size.y - 1
		)
	)


	# -----------------------------------------------------
	# Preview de drag
	# -----------------------------------------------------

	var preview := inventory_grid.create_drag_preview(
		self,
		at_position
	)


	if preview != null:
		set_drag_preview(preview)


	# -----------------------------------------------------
	# Atenuamos la View original mientras arrastramos
	# -----------------------------------------------------

	_is_dragging_self = true

	_modulate_before_drag = self_modulate


	var faded := self_modulate

	faded.a = 0.30

	self_modulate = faded


	# -----------------------------------------------------
	# Datos enviados al destino
	# -----------------------------------------------------

	return {
		"kind": &"inventory_item",
		"item": item_instance,
		"source_grid": inventory_grid,
		"grab_cell_offset": grab_cell_offset
	}


# =========================================================
# FORWARD DROP HACIA INVENTORY GRID
#
# Permite soltar incluso encima de otro
# InventoryItemView.
# =========================================================

func _can_drop_data(
	at_position: Vector2,
	data: Variant
) -> bool:
	if inventory_grid == null:
		return false


	var viewport_point := (
		get_global_transform_with_canvas()
		* at_position
	)


	var grid_local := (
		inventory_grid.make_canvas_position_local(
			viewport_point
		)
	)


	return inventory_grid.can_drop_data_at(
		grid_local,
		data
	)


func _drop_data(
	at_position: Vector2,
	data: Variant
) -> void:
	if inventory_grid == null:
		return


	var viewport_point := (
		get_global_transform_with_canvas()
		* at_position
	)


	var grid_local := (
		inventory_grid.make_canvas_position_local(
			viewport_point
		)
	)


	inventory_grid.drop_data_at(
		grid_local,
		data
	)

func _make_custom_tooltip(
	_for_text: String
) -> Object:
	if (
		item_instance == null
		or
		not item_instance.is_valid()
	):
		return null


	var tooltip := (
		ITEM_TOOLTIP_SCENE.instantiate()
		as ItemTooltip
	)


	if tooltip == null:
		return null


	tooltip.setup(
		item_instance
	)


	return tooltip
