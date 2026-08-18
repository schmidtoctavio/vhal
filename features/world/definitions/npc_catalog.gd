class_name NpcCatalog
extends RefCounted


# =========================================================
# DEFINICIONES
# =========================================================

const WAREHOUSE_KEEPER: NpcDefinition = preload(
	"res://features/world/definitions/catalog/npcs/warehouse_keeper.tres"
)

const GENERAL_MERCHANT: NpcDefinition = preload(
	"res://features/world/definitions/catalog/npcs/general_merchant.tres"
)


# =========================================================
# CATÁLOGO
# =========================================================

static func get_definition(
	npc_id: String
) -> NpcDefinition:
	var normalized_id := (
		npc_id.strip_edges()
	)


	match normalized_id:
		"warehouse_keeper":
			return WAREHOUSE_KEEPER

		"general_merchant":
			return GENERAL_MERCHANT

		_:
			return null
