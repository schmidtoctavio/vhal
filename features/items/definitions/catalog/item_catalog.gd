class_name ItemCatalog
extends RefCounted


# =========================================================
# DEFINICIONES
# =========================================================

const BRONZE_SWORD: ItemDefinition = preload(
	"res://features/items/definitions/catalog/bronze_sword.tres"
)

const HEALTH_POTION: ItemDefinition = preload(
	"res://features/items/definitions/catalog/health_potion.tres"
)

const LEATHER_HELMET: ItemDefinition = preload(
	"res://features/items/definitions/catalog/leather_helmet.tres"
)


# =========================================================
# CATÁLOGO
# =========================================================

static func get_definition(
	item_id: String
) -> ItemDefinition:
	var normalized_id := (
		item_id.strip_edges()
	)


	match normalized_id:
		"bronze_sword":
			return BRONZE_SWORD

		"health_potion":
			return HEALTH_POTION

		"leather_helmet":
			return LEATHER_HELMET

		_:
			return null
