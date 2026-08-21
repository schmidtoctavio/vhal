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

		description_label.text = (
			description
		)


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
	if definition == null:
		return "Objeto"


	match definition.item_type:

		ItemDefinition.ItemType.CONSUMABLE:
			return "Consumible"


		ItemDefinition.ItemType.EQUIPMENT:
			return _get_equipment_type_text(
				definition
			)


		_:
			return "Objeto"


# =========================================================
# EQUIPMENT
# =========================================================

func _get_equipment_type_text(
	definition: ItemDefinition
) -> String:
	if definition == null:
		return "Equipamiento"


	var category_id := (
		definition.get_equipment_category_id()
	)


	match category_id:

		EquipmentCategoryCatalog.HEAD:
			return "Equipamiento · Casco"


		EquipmentCategoryCatalog.CHEST:
			return "Equipamiento · Pechera"


		EquipmentCategoryCatalog.PANTS:
			return "Equipamiento · Pantalones"


		EquipmentCategoryCatalog.GLOVES:
			return "Equipamiento · Guantes"


		EquipmentCategoryCatalog.BOOTS:
			return "Equipamiento · Botas"


		EquipmentCategoryCatalog.WEAPON:
			return _get_weapon_type_text(
				definition
			)


		EquipmentCategoryCatalog.SHIELD:
			return "Equipamiento · Escudo"


		EquipmentCategoryCatalog.WINGS:
			return "Equipamiento · Alas"


		EquipmentCategoryCatalog.PENDANT:
			return "Equipamiento · Pendiente"


		EquipmentCategoryCatalog.RING:
			return "Equipamiento · Anillo"


		_:
			return "Equipamiento"


# =========================================================
# ARMA / MODO DE MANO
# =========================================================

func _get_weapon_type_text(
	definition: ItemDefinition
) -> String:
	if definition == null:
		return "Equipamiento · Arma"


	var hand_mode_id := (
		definition.get_hand_equip_mode_id()
	)


	match hand_mode_id:

		HandEquipModeCatalog.ONE_HAND:
			return "Equipamiento · Arma · Una mano"


		HandEquipModeCatalog.TWO_HAND:
			return "Equipamiento · Arma · Dos manos"


		HandEquipModeCatalog.MAIN_HAND_ONLY:
			return "Equipamiento · Arma · Mano principal"


		HandEquipModeCatalog.OFF_HAND_ONLY:
			return "Equipamiento · Arma · Mano secundaria"


		_:
			return "Equipamiento · Arma"
