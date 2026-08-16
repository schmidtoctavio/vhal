class_name ItemTooltip
extends PanelContainer


# =========================================================
# REFERENCIAS
# =========================================================

@onready var name_label: Label = (
	$Margin/Content/NameLabel
)

@onready var type_label: Label = (
	$Margin/Content/TypeLabel
)

@onready var quantity_label: Label = (
	$Margin/Content/QuantityLabel
)

@onready var size_label: Label = (
	$Margin/Content/SizeLabel
)

@onready var description_label: Label = (
	$Margin/Content/DescriptionLabel
)


# =========================================================
# ITEM
# =========================================================

var _item: ItemInstance = null


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_refresh()


# =========================================================
# SETUP
# =========================================================

func setup(
	item: ItemInstance
) -> void:
	_item = item


	if is_node_ready():
		_refresh()


# =========================================================
# REFRESH
# =========================================================

func _refresh() -> void:
	if not is_node_ready():
		return


	if (
		_item == null
		or
		not _item.is_valid()
	):
		return


	var definition := (
		_item.definition
	)


	# =====================================================
	# NOMBRE
	# =====================================================

	name_label.text = (
		definition.display_name
	)


	# =====================================================
	# TIPO
	# =====================================================

	type_label.text = (
		_get_type_text(
			definition
		)
	)


	# =====================================================
	# CANTIDAD
	# =====================================================

	if _item.is_stackable():
		quantity_label.visible = true

		quantity_label.text = (
			"Cantidad: %d / %d"
			% [
				_item.quantity,
				_item.get_max_stack()
			]
		)

	else:
		quantity_label.visible = false


	# =====================================================
	# TAMAÑO
	# =====================================================

	var grid_size := (
		_item.get_grid_size()
	)


	size_label.text = (
		"Tamaño: %d × %d"
		% [
			grid_size.x,
			grid_size.y
		]
	)


	# =====================================================
	# DESCRIPCIÓN
	# =====================================================

	var description := (
		definition.description.strip_edges()
	)


	if description.is_empty():
		description_label.visible = false

	else:
		description_label.visible = true
		description_label.text = description


	# -----------------------------------------------------
	# Los Labels / Containers necesitan terminar
	# de recalcular su minimum size.
	# -----------------------------------------------------

	call_deferred(
		"_fit_to_content"
	)


func _fit_to_content() -> void:
	reset_size()


# =========================================================
# TIPO GENERAL
# =========================================================

func _get_type_text(
	definition: ItemDefinition
) -> String:
	match definition.item_type:

		ItemDefinition.ItemType.CONSUMABLE:
			return "Consumible"

		ItemDefinition.ItemType.EQUIPMENT:
			return _get_equipment_type_text(
				definition.equipment_type
			)

		_:
			return "Objeto"


# =========================================================
# TIPO DE EQUIPAMIENTO
# =========================================================

func _get_equipment_type_text(
	equipment_type: ItemDefinition.EquipmentType
) -> String:
	match equipment_type:

		ItemDefinition.EquipmentType.HEAD:
			return "Equipamiento · Casco"

		ItemDefinition.EquipmentType.CHEST:
			return "Equipamiento · Pechera"

		ItemDefinition.EquipmentType.PANTS:
			return "Equipamiento · Pantalones"

		ItemDefinition.EquipmentType.GLOVES:
			return "Equipamiento · Guantes"

		ItemDefinition.EquipmentType.BOOTS:
			return "Equipamiento · Botas"

		ItemDefinition.EquipmentType.WEAPON:
			return "Equipamiento · Arma"

		ItemDefinition.EquipmentType.WINGS:
			return "Equipamiento · Alas"

		ItemDefinition.EquipmentType.PENDANT:
			return "Equipamiento · Pendiente"

		ItemDefinition.EquipmentType.RING:
			return "Equipamiento · Anillo"

		_:
			return "Equipamiento"
