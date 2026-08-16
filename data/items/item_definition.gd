@tool
class_name ItemDefinition
extends Resource


enum ItemType {
	MISC,
	CONSUMABLE,
	EQUIPMENT
}


enum EquipmentType {
	NONE,
	HEAD,
	CHEST,
	PANTS,
	GLOVES,
	BOOTS,
	WEAPON,
	WINGS,
	PENDANT,
	RING
}


@export_group("Identity")

@export var item_id: StringName = &"item"

@export var display_name: String = "Item"

@export_multiline var description: String = ""

@export var icon: Texture2D


@export_group("Classification")

@export var item_type: ItemType = ItemType.MISC

@export var equipment_type: EquipmentType = EquipmentType.NONE


@export_group("Inventory")

@export_range(1, 8, 1)
var grid_width: int = 1

@export_range(1, 8, 1)
var grid_height: int = 1

@export_range(1, 9999, 1)
var max_stack: int = 1


func get_grid_size() -> Vector2i:
	return Vector2i(
		grid_width,
		grid_height
	)


func is_equipment() -> bool:
	return (
		item_type == ItemType.EQUIPMENT
		and
		equipment_type != EquipmentType.NONE
	)
