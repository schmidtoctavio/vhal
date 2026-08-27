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

const SKILL_SCROLL_FIRE_BALL: ItemDefinition = preload(
	"res://features/items/definitions/catalog/skill_scroll_fire_ball.tres"
)

const SKILL_SCROLL_POISON: ItemDefinition = preload(
	"res://features/items/definitions/catalog/skill_scroll_poison.tres"
)

const SKILL_SCROLL_HEAL: ItemDefinition = preload(
	"res://features/items/definitions/catalog/skill_scroll_heal.tres"
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

		"skill_scroll_fire_ball":
			return SKILL_SCROLL_FIRE_BALL

		"skill_scroll_poison":
			return SKILL_SCROLL_POISON

		"skill_scroll_heal":
			return SKILL_SCROLL_HEAL

		_:
			return null
