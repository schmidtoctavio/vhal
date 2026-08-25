class_name WorldDropActor
extends Node3D


# =========================================================
# ESTADO
# =========================================================

var entity_id: String = ""

var item_id: String = ""

var quantity: int = 0

var map_id: String = ""


# =========================================================
# REFERENCIAS
# =========================================================

@onready var item_sprite: Sprite3D = (
	$VisualRoot/ItemSprite
)


@onready var name_label: Label3D = (
	$VisualRoot/NameLabel
)


# =========================================================
# SETUP
# =========================================================

func setup(
	snapshot: Dictionary
) -> bool:
	if snapshot.is_empty():
		return false


	var new_entity_id := String(
		snapshot.get(
			"entity_id",
			""
		)
	).strip_edges().to_lower()


	var entity_kind := String(
		snapshot.get(
			"entity_kind",
			""
		)
	).strip_edges().to_lower()


	if (
		new_entity_id.is_empty()
		or
		entity_kind != "world_drop"
	):
		return false


	var item_value: Variant = (
		snapshot.get(
			"item",
			null
		)
	)


	if typeof(item_value) != TYPE_DICTIONARY:
		return false


	var item: Dictionary = (
		item_value
	)


	var new_item_id := String(
		item.get(
			"item_id",
			""
		)
	).strip_edges().to_lower()


	var new_quantity := int(
		item.get(
			"quantity",
			0
		)
	)


	if (
		new_item_id.is_empty()
		or
		new_quantity <= 0
	):
		return false


	var definition := (
		ItemCatalog.get_definition(
			new_item_id
		)
	)


	if definition == null:
		return false


	var world_value: Variant = (
		snapshot.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return false


	var world: Dictionary = (
		world_value
	)


	var new_map_id := String(
		world.get(
			"map_id",
			""
		)
	).strip_edges()


	var position_value: Variant = (
		world.get(
			"position",
			null
		)
	)


	if (
		new_map_id.is_empty()
		or
		typeof(position_value) != TYPE_VECTOR3
	):
		return false


	entity_id = new_entity_id

	item_id = new_item_id

	quantity = new_quantity

	map_id = new_map_id

	position = (
		position_value
		as Vector3
	)


	name = (
		"WorldDrop_%s"
		%
		entity_id
	)


	if item_sprite != null:
		item_sprite.texture = (
			definition.icon
		)


	if name_label != null:
		name_label.text = (
			"%s x%d"
			%
			[
				definition.display_name,
				quantity,
			]
		)


	print(
		"WorldDropActor | Preparado",
		" | Entity: ",
		entity_id,
		" | Item: ",
		item_id,
		" | Quantity: ",
		quantity,
		" | Posición: ",
		position
	)


	return true

func get_entity_id() -> String:
	return entity_id
