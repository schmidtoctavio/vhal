class_name AccountState
extends RefCounted


# =========================================================
# CONFIGURACIÓN
# =========================================================

const VAULT_COLUMNS: int = 8
const VAULT_ROWS: int = 16


# =========================================================
# VAULT
# =========================================================

var vault: InventoryData = null


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init() -> void:
	vault = InventoryData.new(
		VAULT_COLUMNS,
		VAULT_ROWS
	)

# =========================================================
# APLICAR SNAPSHOT DE VAULT
# =========================================================

func apply_vault_snapshot(
	snapshot: Dictionary
) -> bool:
	var container := String(
		snapshot.get(
			"container",
			""
		)
	).strip_edges()


	if container != "vault":
		return false


	var items_value: Variant = (
		snapshot.get(
			"items",
			null
		)
	)


	if typeof(items_value) != TYPE_ARRAY:
		return false


	var snapshot_items: Array = (
		items_value as Array
	)


	# -----------------------------------------------------
	# Construimos primero una Vault NUEVA.
	#
	# Sólo reemplazamos la actual cuando TODO el snapshot
	# pudo reconstruirse correctamente.
	# -----------------------------------------------------

	var candidate_vault := InventoryData.new(
		VAULT_COLUMNS,
		VAULT_ROWS
	)


	for item_value in snapshot_items:
		if typeof(item_value) != TYPE_DICTIONARY:
			return false


		var item_data: Dictionary = (
			item_value
		)


		var uid := String(
			item_data.get(
				"uid",
				""
			)
		).strip_edges()


		var item_id := String(
			item_data.get(
				"item_id",
				""
			)
		).strip_edges()


		var quantity := int(
			item_data.get(
				"quantity",
				0
			)
		)


		if uid.is_empty():
			return false


		if item_id.is_empty():
			return false


		if quantity <= 0:
			return false


		var definition := (
			ItemCatalog.get_definition(
				item_id
			)
		)


		if definition == null:
			print(
				"AccountState | ItemDefinition desconocida en Vault: ",
				item_id
			)


			return false


		var position_value: Variant = (
			item_data.get(
				"grid_position",
				null
			)
		)


		if typeof(position_value) != TYPE_DICTIONARY:
			return false


		var position_data: Dictionary = (
			position_value
		)


		var grid_position := Vector2i(
			int(
				position_data.get(
					"x",
					-1
				)
			),
			int(
				position_data.get(
					"y",
					-1
				)
			)
		)


		if (
			grid_position.x < 0
			or
			grid_position.y < 0
		):
			return false


		var persistent_state: Dictionary = {}


		var state_value: Variant = (
			item_data.get(
				"state",
				null
			)
		)


		if typeof(state_value) == TYPE_DICTIONARY:
			persistent_state = (
				state_value as Dictionary
			).duplicate(
				true
			)


		var item := ItemInstance.new(
			definition,
			quantity,
			grid_position,
			uid,
			persistent_state
		)


		if not candidate_vault.add_item(
			item
		):
			print(
				"AccountState | Item persistente no pudo ubicarse",
				" | UID: ",
				uid,
				" | Item: ",
				item_id,
				" | Posición: ",
				grid_position
			)


			return false


	# -----------------------------------------------------
	# SNAPSHOT COMPLETO Y VÁLIDO
	# -----------------------------------------------------

	vault = candidate_vault


	print(
		"AccountState | Vault persistente reconstruida",
		" | Items: ",
		vault.items.size()
	)


	return true
