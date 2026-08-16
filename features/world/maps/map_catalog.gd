class_name MapCatalog
extends RefCounted


# =========================================================
# DEFINICIONES
# =========================================================

const TEST_TOWN: MapDefinition = preload(
	"res://world/maps/test_town/test_town.tres"
)


# =========================================================
# OBTENER MAPA
# =========================================================

static func get_definition(
	map_id: String
) -> MapDefinition:
	var normalized_id := (
		map_id.strip_edges()
	)


	match normalized_id:
		"test_town":
			return TEST_TOWN

		_:
			return null
