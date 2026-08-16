class_name MapCatalog
extends RefCounted


# =========================================================
# RUTAS DE DEFINICIONES
# =========================================================

const MAP_DEFINITION_PATHS: Dictionary = {
	"test_town": (
		"res://world/definitions/catalog/test_town.tres"
	),
}


# =========================================================
# OBTENER MAPA
# =========================================================

static func get_definition(
	map_id: String
) -> MapDefinition:
	var normalized_id := (
		map_id.strip_edges()
	)


	if normalized_id.is_empty():
		return null


	var definition_path := String(
		MAP_DEFINITION_PATHS.get(
			normalized_id,
			""
		)
	)


	if definition_path.is_empty():
		return null


	var definition_resource: Resource = (
		ResourceLoader.load(
			definition_path
		)
	)


	return (
		definition_resource
		as MapDefinition
	)
