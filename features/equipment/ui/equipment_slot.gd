class_name EquipmentSlot
extends Button

const ITEM_TOOLTIP_SCENE := preload(
    "res://features/items/ui/item_tooltip.tscn"
)

signal item_activated(
	slot_id: StringName,
	item: ItemInstance
)

# =========================================================
# CONFIGURACIÓN
# =========================================================

@export_group("Equipment")

@export var slot_id: StringName = (
	EquipmentSlotCatalog.HEAD
)


@export_group("Visual")

@export var placeholder_icon: Texture2D


@export var valid_drop_tint := Color(
	0.75,
	1.00,
	0.75,
	1.00
)

@export var invalid_drop_tint := Color(
	1.00,
	0.65,
	0.65,
	1.00
)


# =========================================================
# MODELO
# =========================================================

var equipment_data: EquipmentData = null


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	slot_id = (
		EquipmentSlotCatalog.normalize_slot_id(
			slot_id
		)
	)


	if not EquipmentSlotCatalog.is_valid_slot_id(
		slot_id
	):
		push_error(
			(
				"EquipmentSlot | slot_id inválido: "
				+
				String(slot_id)
			)
		)


	mouse_filter = Control.MOUSE_FILTER_STOP

func _notification(
	what: int
) -> void:
	if what == NOTIFICATION_DRAG_END:
		_reset_drop_feedback()


# =========================================================
# BIND
# =========================================================

func bind_equipment_data(
	data: EquipmentData
) -> void:
	if equipment_data == data:
		_refresh()
		return


	_disconnect_equipment_data()


	equipment_data = data


	_connect_equipment_data()

	_refresh()


# =========================================================
# SIGNALS
# =========================================================

func _connect_equipment_data() -> void:
	if equipment_data == null:
		return


	if not equipment_data.item_equipped.is_connected(
		_on_item_equipped
	):
		equipment_data.item_equipped.connect(
			_on_item_equipped
		)


	if not equipment_data.item_unequipped.is_connected(
		_on_item_unequipped
	):
		equipment_data.item_unequipped.connect(
			_on_item_unequipped
		)


func _disconnect_equipment_data() -> void:
	if equipment_data == null:
		return


	if equipment_data.item_equipped.is_connected(
		_on_item_equipped
	):
		equipment_data.item_equipped.disconnect(
			_on_item_equipped
		)


	if equipment_data.item_unequipped.is_connected(
		_on_item_unequipped
	):
		equipment_data.item_unequipped.disconnect(
			_on_item_unequipped
		)


# =========================================================
# EVENTOS
# =========================================================

func _on_item_equipped(
	changed_slot_id: StringName,
	_item: ItemInstance
) -> void:
	if changed_slot_id != slot_id:
		return


	_refresh()


func _on_item_unequipped(
	changed_slot_id: StringName,
	_item: ItemInstance
) -> void:
	if changed_slot_id != slot_id:
		return


	_refresh()


# =========================================================
# CONSULTAR ITEM
# =========================================================

func get_item() -> ItemInstance:
	if equipment_data == null:
		return null

	return equipment_data.get_item(
		slot_id
	)


func has_item() -> bool:
	return get_item() != null


# =========================================================
# VISUAL
# =========================================================

func _refresh() -> void:
	var item_icon := get_node_or_null(
		"IconMargin/ItemIcon"
	) as TextureRect


	var placeholder := get_node_or_null(
		"PlaceholderIcon"
	) as TextureRect


	var item := get_item()


	# =====================================================
	# ITEM EQUIPADO
	# =====================================================

	if item != null:
		tooltip_text = "item"


		if item_icon:
			item_icon.texture = (
				item.definition.icon
			)

			item_icon.visible = true


		if placeholder:
			placeholder.visible = false


		return


	# =====================================================
	# SLOT VACÍO
	# =====================================================

	tooltip_text = ""


	if item_icon:
		item_icon.texture = null
		item_icon.visible = false


	if placeholder:
		placeholder.texture = (
			placeholder_icon
		)

		placeholder.visible = (
			placeholder_icon != null
		)

# =========================================================
# DRAG DATA
# =========================================================

func _is_inventory_drag_data(
	data: Variant
) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false


	var dictionary := data as Dictionary


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


	if not (
		dictionary["item"]
		is ItemInstance
	):
		return false


	if not (
		dictionary["source_grid"]
		is InventoryGrid
	):
		return false


	return true


# =========================================================
# VALIDAR DROP
# =========================================================

func _can_drop_data(
	_at_position: Vector2,
	data: Variant
) -> bool:
	if equipment_data == null:
		_reset_drop_feedback()
		return false


	if not EquipmentSlotCatalog.is_valid_slot_id(
		slot_id
	):
		_reset_drop_feedback()
		return false


	if not _is_inventory_drag_data(
		data
	):
		_reset_drop_feedback()
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


	if (
		source_grid == null
		or
		source_grid.inventory_data == null
	):
		_reset_drop_feedback()
		return false


	# -----------------------------------------------------
	# Mientras Equipment todavía no tenga su protocolo
	# autoritativo, no permitimos mutación local cuando
	# Inventory está trabajando en authoritative mode.
	# -----------------------------------------------------

	if source_grid.authoritative_move_only:
		_set_drop_feedback(
			false
		)

		return false


	var valid := (
		equipment_data.can_equip(
			slot_id,
			item
		)
	)


	_set_drop_feedback(
		valid
	)


	return valid




# =========================================================
# EJECUTAR DROP
# =========================================================

func _drop_data(
	_at_position: Vector2,
	data: Variant
) -> void:
	_reset_drop_feedback()


	if equipment_data == null:
		return


	if not _is_inventory_drag_data(
		data
	):
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


	if (
		source_grid == null
		or
		source_grid.inventory_data == null
	):
		return

	if source_grid.authoritative_move_only:
		return

	var success := (
		equipment_data.equip_from_inventory(
			source_grid.inventory_data,
			item,
			slot_id
		)
	)


	if not success:
		print(
			"No se pudo equipar ",
			item.definition.display_name,
			" en slot ",
			slot_id
		)

# =========================================================
# DRAG SOURCE
# EQUIPMENT -> INVENTORY
# =========================================================

func _get_drag_data(
	at_position: Vector2
) -> Variant:
	if Engine.is_editor_hint():
		return null


	if equipment_data == null:
		return null


	var item := get_item()


	if item == null:
		return null


	if not item.is_valid():
		return null


	# -----------------------------------------------------
	# PREVIEW VISUAL
	# -----------------------------------------------------

	var preview := TextureRect.new()


	preview.texture = (
		item.definition.icon
	)


	preview.expand_mode = (
		TextureRect.EXPAND_IGNORE_SIZE
	)


	preview.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)


	preview.custom_minimum_size = size

	preview.size = size


	preview.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


	preview.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.80
	)


	# Conservamos aproximadamente el punto
	# desde donde agarramos el slot.
	preview.position = (
		-at_position
	)


	set_drag_preview(
		preview
	)


	# -----------------------------------------------------
	# DATOS DEL DRAG
	# -----------------------------------------------------

	return {
		"kind": &"equipment_item",
		"item": item,
		"source_equipment_data": equipment_data,
		"source_slot_id": slot_id,
		"grab_cell_offset": Vector2i.ZERO
	}

# =========================================================
# DOBLE CLIC SOBRE ITEM EQUIPADO
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


	var item := get_item()


	if item == null:
		return


	item_activated.emit(
		slot_id,
		item
	)


	accept_event()

# =========================================================
# TOOLTIP
# =========================================================

func _make_custom_tooltip(
	for_text: String
) -> Object:
	if for_text.is_empty():
		return null


	var item := get_item()


	if item == null:
		return null


	if not item.is_valid():
		return null


	var tooltip := (
		ITEM_TOOLTIP_SCENE.instantiate()
		as ItemTooltip
	)


	if tooltip == null:
		return null


	tooltip.setup(
		item
	)


	return tooltip


# =========================================================
# FEEDBACK TEMPORAL
# =========================================================

func _set_drop_feedback(
	valid: bool
) -> void:
	if valid:
		modulate = valid_drop_tint
	else:
		modulate = invalid_drop_tint


func _reset_drop_feedback() -> void:
	modulate = Color.WHITE
