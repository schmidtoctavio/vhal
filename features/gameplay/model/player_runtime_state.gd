class_name PlayerRuntimeState
extends RefCounted


# =========================================================
# IDENTIDAD
# =========================================================

var character_summary: CharacterSummary = null

# =========================================================
# MUNDO
# =========================================================

var world: PlayerWorldState = null

# =========================================================
# VITALES
# =========================================================

var vitals: VitalsState = null

# =========================================================
# EXPERIENCIA
# =========================================================

var experience: ExperienceState = null

# =========================================================
# INVENTARIO
# =========================================================

var inventory: InventoryData = null


# =========================================================
# EQUIPAMIENTO
# =========================================================

var equipment: EquipmentData = null


# =========================================================
# SKILLS
# =========================================================

var skill_book: SkillBookData = null

var skill_hotbar: SkillHotbarData = null


# =========================================================
# MONEDA
# =========================================================

var currency: CurrencyState = null


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	summary: CharacterSummary = null
) -> void:
	character_summary = summary


	world = PlayerWorldState.new()


	vitals = VitalsState.new()


	experience = ExperienceState.new()


	inventory = InventoryData.new()


	equipment = EquipmentData.new()


	skill_book = SkillBookData.new()


	skill_hotbar = SkillHotbarData.new()


	currency = CurrencyState.new()


# =========================================================
# INVENTORY PERSISTENTE
# =========================================================

const INVENTORY_COLUMNS: int = 8
const INVENTORY_ROWS: int = 8


func apply_inventory_snapshot(
	snapshot: Dictionary
) -> bool:
	var container := String(
		snapshot.get(
			"container",
			""
		)
	).strip_edges()


	if container != "inventory":
		return false


	var character_id := int(
		snapshot.get(
			"character_id",
			0
		)
	)


	if character_id <= 0:
		return false


	if (
		character_summary != null
		and
		character_summary.character_id != character_id
	):
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


	var candidate_inventory := InventoryData.new(
		INVENTORY_COLUMNS,
		INVENTORY_ROWS
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
				(
					"PlayerRuntimeState | ItemDefinition "
					+
					"desconocida en Inventory: "
				),
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


		if not candidate_inventory.add_item(
			item
		):
			print(
				"PlayerRuntimeState | Item persistente no pudo ubicarse",
				" | UID: ",
				uid,
				" | Item: ",
				item_id,
				" | Posición: ",
				grid_position
			)


			return false


	inventory = candidate_inventory


	print(
		"PlayerRuntimeState | Inventory persistente reconstruido",
		" | Items: ",
		inventory.items.size()
	)


	return true
