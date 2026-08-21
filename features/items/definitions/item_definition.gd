@tool
class_name ItemDefinition
extends Resource


# =========================================================
# TIPO GENERAL
# =========================================================
#
# Este enum sigue siendo una ayuda LOCAL de authoring.
#
# La identidad de Equipment que cruzará sistemas utiliza
# IDs semánticos estables.
# =========================================================

enum ItemType {
	MISC,
	CONSUMABLE,
	EQUIPMENT
}


# =========================================================
# IDENTIDAD
# =========================================================

@export_group("Identity")

@export var item_id: StringName = &"item"

@export var display_name: String = "Item"

@export_multiline var description: String = ""

@export var icon: Texture2D


# =========================================================
# CLASIFICACIÓN GENERAL
# =========================================================

@export_group("Classification")

@export var item_type: ItemType = ItemType.MISC


# =========================================================
# EQUIPMENT
# =========================================================
#
# Se almacenan como String para que Godot pueda mostrar un
# selector @export_enum cómodo, pero conceptualmente son
# IDs semánticos estables.
# =========================================================

@export_group("Equipment")

@export_enum(
	"none",
	"head",
	"chest",
	"pants",
	"gloves",
	"boots",
	"weapon",
	"shield",
	"wings",
	"pendant",
	"ring"
)
var equipment_category_id: String = "none"


@export_enum(
	"none",
	"main_hand_only",
	"one_hand",
	"two_hand",
	"off_hand_only"
)
var hand_equip_mode_id: String = "none"


# =========================================================
# INVENTORY
# =========================================================

@export_group("Inventory")

@export_range(1, 8, 1)
var grid_width: int = 1

@export_range(1, 8, 1)
var grid_height: int = 1

@export_range(1, 9999, 1)
var max_stack: int = 1


# =========================================================
# GRID
# =========================================================

func get_grid_size() -> Vector2i:
	return Vector2i(
		grid_width,
		grid_height
	)


# =========================================================
# EQUIPMENT METADATA
# =========================================================

func get_equipment_category_id() -> StringName:
	return EquipmentCategoryCatalog.normalize_category_id(
		equipment_category_id
	)


func get_hand_equip_mode_id() -> StringName:
	return HandEquipModeCatalog.normalize_mode_id(
		hand_equip_mode_id
	)


func is_equipment() -> bool:
	if item_type != ItemType.EQUIPMENT:
		return false


	return EquipmentCategoryCatalog.is_equipment_category(
		get_equipment_category_id()
	)
