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
# PRIMARY STATS
# =========================================================

var primary_stats: PrimaryStatsState = null

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

var skill_cooldowns: SkillCooldownState = null

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

	primary_stats = PrimaryStatsState.new()

	inventory = InventoryData.new()


	equipment = EquipmentData.new()


	skill_book = SkillBookData.new()


	skill_hotbar = SkillHotbarData.new()


	skill_cooldowns = SkillCooldownState.new()


	currency = CurrencyState.new()

# =========================================================
# VITALES AUTORITATIVOS
# =========================================================

func apply_vitals_snapshot(
	snapshot: Dictionary
) -> bool:
	if vitals == null:
		return false


	if (
		not snapshot.has("hp")
		or
		not snapshot.has("max_hp")
		or
		not snapshot.has("mp")
		or
		not snapshot.has("max_mp")
	):
		return false


	var hp := int(
		snapshot["hp"]
	)


	var max_hp := int(
		snapshot["max_hp"]
	)


	var mp := int(
		snapshot["mp"]
	)


	var max_mp := int(
		snapshot["max_mp"]
	)


	if max_hp <= 0:
		return false


	if hp < 0 or hp > max_hp:
		return false


	if max_mp <= 0:
		return false


	if mp < 0 or mp > max_mp:
		return false


	vitals.set_max_hp(
		max_hp
	)


	vitals.set_hp(
		hp
	)


	vitals.set_max_mp(
		max_mp
	)


	vitals.set_mp(
		mp
	)


	print(
		"PlayerRuntimeState | Vitals autoritativos aplicados",
		" | HP: ",
		hp,
		"/",
		max_hp,
		" | MP: ",
		mp,
		"/",
		max_mp
	)


	return true


# =========================================================
# PROGRESIÓN AUTORITATIVA
# =========================================================

func apply_progression_snapshot(
	snapshot: Dictionary
) -> bool:
	if character_summary == null:
		return false


	if experience == null:
		return false


	var level := int(
		snapshot.get(
			"level",
			0
		)
	)


	var current_experience := int(
		snapshot.get(
			"experience",
			-1
		)
	)


	var experience_required := int(
		snapshot.get(
			"experience_required",
			0
		)
	)


	if level <= 0:
		return false


	if current_experience < 0:
		return false


	if experience_required <= 0:
		return false


	if current_experience >= experience_required:
		return false


	character_summary.level = level


	experience.set_experience_required(
		experience_required
	)


	experience.set_experience(
		current_experience
	)


	print(
		"PlayerRuntimeState | Progression autoritativa aplicada",
		" | Level: ",
		level,
		" | EXP: ",
		current_experience,
		"/",
		experience_required
	)


	return true

# =========================================================
# PRIMARY STATS AUTORITATIVOS
# =========================================================

func apply_primary_stats_snapshot(
	snapshot: Dictionary
) -> bool:
	if primary_stats == null:
		return false


	if character_summary == null:
		return false


	var progression_value: Variant = (
		snapshot.get(
			"progression",
			null
		)
	)


	if typeof(progression_value) != TYPE_DICTIONARY:
		return false


	var progression: Dictionary = (
		progression_value
	)


	var snapshot_level := int(
		progression.get(
			"level",
			0
		)
	)


	if (
		snapshot_level
		!=
		character_summary.level
	):
		return false


	if not primary_stats.apply_snapshot(
		snapshot
	):
		return false


	print(
		"PlayerRuntimeState | Primary Stats autoritativos aplicados",
		" | Revision: ",
		primary_stats.revision,
		" | STR B/A/P: ",
		primary_stats.base_strength,
		"/",
		primary_stats.allocated_strength,
		"/",
		primary_stats.permanent_strength,
		" | AGI B/A/P: ",
		primary_stats.base_agility,
		"/",
		primary_stats.allocated_agility,
		"/",
		primary_stats.permanent_agility,
		" | VIT B/A/P: ",
		primary_stats.base_vitality,
		"/",
		primary_stats.allocated_vitality,
		"/",
		primary_stats.permanent_vitality,
		" | ENE B/A/P: ",
		primary_stats.base_energy,
		"/",
		primary_stats.allocated_energy,
		"/",
		primary_stats.permanent_energy,
		" | Points: ",
		primary_stats.spent_points,
		"/",
		primary_stats.total_points,
		" | Unspent: ",
		primary_stats.unspent_points
	)


	return true

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

# =========================================================
# EQUIPMENT PERSISTENTE
# =========================================================

func apply_equipment_snapshot(
	snapshot: Dictionary
) -> bool:
	var container := String(
		snapshot.get(
			"container",
			""
		)
	).strip_edges()


	if container != "equipment":
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


	var candidate_equipment := (
		EquipmentData.new()
	)


	var seen_uids: Dictionary = {}


	for item_value: Variant in snapshot_items:
		if typeof(item_value) != TYPE_DICTIONARY:
			return false


		var item_data: Dictionary = (
			item_value
		)


		# -------------------------------------------------
		# IDENTIDAD PERSISTENTE
		# -------------------------------------------------

		var uid := String(
			item_data.get(
				"uid",
				""
			)
		).strip_edges()


		if uid.is_empty():
			return false


		if seen_uids.has(
			uid
		):
			print(
				"PlayerRuntimeState | UID duplicado en Equipment",
				" | UID: ",
				uid
			)


			return false


		seen_uids[
			uid
		] = true


		# -------------------------------------------------
		# ITEM DEFINITION
		# -------------------------------------------------

		var item_id := String(
			item_data.get(
				"item_id",
				""
			)
		).strip_edges()


		if item_id.is_empty():
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
					"desconocida en Equipment: "
				),
				item_id
			)


			return false


		if not EquipmentRules.is_definition_configuration_valid(
			definition
		):
			print(
				"PlayerRuntimeState | ItemDefinition inválida para Equipment",
				" | Item: ",
				item_id
			)


			return false


		# -------------------------------------------------
		# QUANTITY
		#
		# Equipment representa una instancia concreta.
		# No aceptamos stacks equipados.
		# -------------------------------------------------

		var quantity := int(
			item_data.get(
				"quantity",
				0
			)
		)


		if quantity != 1:
			print(
				"PlayerRuntimeState | Cantidad inválida en Equipment",
				" | UID: ",
				uid,
				" | Quantity: ",
				quantity
			)


			return false


		# -------------------------------------------------
		# SLOT SEMÁNTICO
		# -------------------------------------------------

		var slot_id := (
			EquipmentSlotCatalog.normalize_slot_id(
				item_data.get(
					"equipment_slot",
					""
				)
			)
		)


		if not EquipmentSlotCatalog.is_valid_slot_id(
			slot_id
		):
			print(
				"PlayerRuntimeState | Slot inválido en Equipment",
				" | UID: ",
				uid,
				" | Slot: ",
				item_data.get(
					"equipment_slot",
					""
				)
			)


			return false


		if not EquipmentRules.can_definition_use_slot(
			definition,
			slot_id
		):
			print(
				"PlayerRuntimeState | Item incompatible con slot",
				" | Item: ",
				item_id,
				" | Slot: ",
				slot_id
			)


			return false


		# -------------------------------------------------
		# EQUIPMENT NO TIENE POSICIÓN DE GRID
		# -------------------------------------------------

		if item_data.has(
			"grid_position"
		):
			print(
				"PlayerRuntimeState | Equipment recibió grid_position",
				" | UID: ",
				uid
			)


			return false


		# -------------------------------------------------
		# STATE PERSISTENTE
		# -------------------------------------------------

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


		# -------------------------------------------------
		# RECONSTRUIR INSTANCIA
		#
		# grid_position no tiene significado mientras el
		# item está equipado, por eso queda Vector2i.ZERO.
		# La identidad del slot vive en EquipmentData.
		# -------------------------------------------------

		var item := ItemInstance.new(
			definition,
			1,
			Vector2i.ZERO,
			uid,
			persistent_state
		)


		if not candidate_equipment.equip_item(
			slot_id,
			item
		):
			print(
				"PlayerRuntimeState | Item persistente no pudo equiparse",
				" | UID: ",
				uid,
				" | Item: ",
				item_id,
				" | Slot: ",
				slot_id
			)


			return false


	# -----------------------------------------------------
	# VALIDACIÓN FINAL DEL SNAPSHOT COMPLETO
	#
	# Importante para reservas como TWO_HAND -> OFF_HAND.
	# -----------------------------------------------------

	if not EquipmentRules.validate_equipment_state(
		candidate_equipment.get_equipped_items()
	):
		print(
			"PlayerRuntimeState | Estado persistente de Equipment inválido"
		)


		return false


	# -----------------------------------------------------
	# REEMPLAZO ATÓMICO
	#
	# Nunca destruimos el estado bueno hasta haber
	# reconstruido y validado completamente el candidato.
	# -----------------------------------------------------

	equipment = candidate_equipment


	print(
		"PlayerRuntimeState | Equipment persistente reconstruido",
		" | Items: ",
		equipment.get_equipped_items().size()
	)


	return true


# =========================================================
# SKILLS AUTORITATIVAS
# =========================================================

func apply_skill_snapshot(
	snapshot: Dictionary
) -> bool:
	if skill_book == null:
		return false


	if skill_hotbar == null:
		return false


	var learned_skill_ids_value: Variant = (
		snapshot.get(
			"learned_skill_ids",
			null
		)
	)


	if typeof(learned_skill_ids_value) != TYPE_ARRAY:
		return false


	# -----------------------------------------------------
	# El runtime recién creado debe estar limpio.
	# -----------------------------------------------------

	if skill_book.get_skill_count() != 0:
		return false


	var learned_definitions: Dictionary = {}


	for skill_id_value: Variant in (
		learned_skill_ids_value
		as Array
	):
		var skill_id := String(
			skill_id_value
		).strip_edges().to_lower()


		if skill_id.is_empty():
			return false


		if learned_definitions.has(
			skill_id
		):
			return false


		var definition := (
			ClientSkillCatalog.get_definition(
				skill_id
			)
		)


		if definition == null:
			return false


		if not skill_book.learn_skill(
			definition
		):
			return false


		learned_definitions[
			skill_id
		] = definition


	# -----------------------------------------------------
	# HOTBAR DEFAULT FOUNDATION
	#
	# El orden de hotbar es preferencia del cliente,
	# no autoridad de gameplay.
	# -----------------------------------------------------

	var hotbar_index: int = 0


	for skill_id: String in (
		ClientSkillCatalog.DEFAULT_HOTBAR_ORDER
	):
		if hotbar_index >= SkillHotbarData.SLOT_COUNT:
			break


		if not learned_definitions.has(
			skill_id
		):
			continue


		var definition: SkillDefinition = (
			learned_definitions[
				skill_id
			]
		)


		if not skill_hotbar.set_skill(
			hotbar_index,
			definition
		):
			return false


		hotbar_index += 1


	print(
		"PlayerRuntimeState | Skills autoritativas aplicadas",
		" | Learned: ",
		skill_book.get_skill_count(),
		" | Hotbar slots: ",
		hotbar_index
	)


	return true


# =========================================================
# SKILLS AUTORITATIVAS — ACTUALIZACIÓN EN VIVO
# =========================================================

func apply_skill_learning_update(
	learned_skill_ids: PackedStringArray
) -> bool:
	if skill_book == null:
		return false


	if skill_hotbar == null:
		return false


	# -----------------------------------------------------
	# VALIDAR SNAPSHOT COMPLETO ANTES DE MUTAR
	#
	# skill_learning_result contiene el ownership completo
	# conocido por el Game Server después del aprendizaje.
	# -----------------------------------------------------

	var normalized_skill_ids: Array[String] = []

	var definitions_by_id: Dictionary = {}


	for skill_id_value in learned_skill_ids:
		var skill_id := String(
			skill_id_value
		).strip_edges().to_lower()


		if skill_id.is_empty():
			return false


		if definitions_by_id.has(
			skill_id
		):
			return false


		var definition := (
			ClientSkillCatalog.get_definition(
				skill_id
			)
		)


		if definition == null:
			return false


		normalized_skill_ids.append(
			skill_id
		)


		definitions_by_id[
			skill_id
		] = definition


	# -----------------------------------------------------
	# UN APRENDIZAJE NO PUEDE QUITAR SKILLS
	#
	# Si el resultado autoritativo omitiera una Skill que
	# ya teníamos, hay una inconsistencia y fallamos cerrado.
	# -----------------------------------------------------

	for current_skill: SkillDefinition in (
		skill_book.get_skills()
	):
		if current_skill == null:
			return false


		var current_skill_id := String(
			current_skill.skill_id
		).strip_edges().to_lower()


		if not definitions_by_id.has(
			current_skill_id
		):
			return false


	# -----------------------------------------------------
	# AGREGAR ÚNICAMENTE LAS SKILLS NUEVAS
	# -----------------------------------------------------

	var newly_learned_ids: Dictionary = {}


	for skill_id: String in normalized_skill_ids:
		if skill_book.has_skill_id(
			StringName(
				skill_id
			)
		):
			continue


		var definition := (
			definitions_by_id[
				skill_id
			]
			as SkillDefinition
		)


		if definition == null:
			return false


		if not skill_book.learn_skill(
			definition
		):
			return false


		newly_learned_ids[
			skill_id
		] = true


	# -----------------------------------------------------
	# HOTBAR
	#
	# Sólo autoasignamos Skills NUEVAS.
	#
	# No rellenamos Skills antiguas que el jugador haya
	# decidido quitar manualmente de su hotbar.
	# -----------------------------------------------------

	var hotbar_added: int = 0


	for skill_id: String in (
		ClientSkillCatalog.DEFAULT_HOTBAR_ORDER
	):
		if not newly_learned_ids.has(
			skill_id
		):
			continue


		var definition := (
			definitions_by_id[
				skill_id
			]
			as SkillDefinition
		)


		if definition == null:
			return false


		if skill_hotbar.find_skill_index(
			definition
		) >= 0:
			continue


		var empty_index: int = -1


		for index: int in range(
			SkillHotbarData.SLOT_COUNT
		):
			if skill_hotbar.get_skill(
				index
			) != null:
				continue


			empty_index = index

			break


		if empty_index < 0:
			break


		if not skill_hotbar.set_skill(
			empty_index,
			definition
		):
			return false


		hotbar_added += 1


	print(
		"PlayerRuntimeState | Skills autoritativas actualizadas en vivo",
		" | Learned: ",
		skill_book.get_skill_count(),
		" | Nuevas: ",
		newly_learned_ids.size(),
		" | Hotbar agregadas: ",
		hotbar_added
	)


	return true
