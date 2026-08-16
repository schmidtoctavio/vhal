@tool
class_name ItemSlot
extends Button


# =========================================================
# ITEM
# =========================================================

@export_group("Item")


@export var item_definition: ItemDefinition:
	set(value):
		item_definition = value
		_refresh()


@export_range(0, 9999, 1)
var quantity: int = 0:
	set(value):
		quantity = maxi(
			value,
			0
		)

		_refresh()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh()


# =========================================================
# API
# =========================================================

func set_item(
	definition: ItemDefinition,
	new_quantity: int = 1
) -> void:
	item_definition = definition
	quantity = maxi(
		new_quantity,
		0
	)

	_refresh()


func clear_item() -> void:
	item_definition = null
	quantity = 0

	_refresh()


func has_item() -> bool:
	return (
		item_definition != null
		and
		quantity > 0
	)


# =========================================================
# VISUAL
# =========================================================

func _refresh() -> void:
	var icon_rect := get_node_or_null(
		"IconMargin/ItemIcon"
	) as TextureRect

	var quantity_label := get_node_or_null(
		"QuantityLabel"
	) as Label


	var occupied := has_item()


	# -----------------------------------------------------
	# ICONO
	# -----------------------------------------------------

	if icon_rect:
		if occupied:
			icon_rect.texture = (
				item_definition.icon
			)
		else:
			icon_rect.texture = null

		icon_rect.visible = occupied


	# -----------------------------------------------------
	# CANTIDAD
	# -----------------------------------------------------

	if quantity_label:
		var show_quantity := (
			occupied
			and
			quantity > 1
		)

		quantity_label.visible = (
			show_quantity
		)

		if show_quantity:
			quantity_label.text = str(
				quantity
			)
		else:
			quantity_label.text = ""
