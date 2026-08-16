class_name MockGameSessionService
extends GameSessionService


# =========================================================
# VALORES MOCK TEMPORALES
# =========================================================

const MOCK_MAX_HP: int = 100000
const MOCK_MAX_MP: int = 350


# =========================================================
# ESTADO MOCK
# =========================================================

var active_character_id: int = -1

var active_player_state: PlayerRuntimeState = null


# =========================================================
# ENTRAR AL MUNDO
# =========================================================

func start_session(
	account_id: int,
	character_id: int
) -> void:
	if account_id < 0:
		session_failed.emit(
			"La cuenta no es válida."
		)

		return


	if character_id < 0:
		session_failed.emit(
			"El personaje no es válido."
		)

		return


	active_character_id = character_id


	active_player_state = (
		PlayerRuntimeState.new()
	)


	_setup_mock_vitals(
		active_player_state
	)


	_setup_mock_inventory(
		active_player_state
	)


	_setup_mock_skills(
		active_player_state
	)


	session_started.emit(
		active_character_id,
		active_player_state
	)


# =========================================================
# VITALES MOCK TEMPORALES
# =========================================================

func _setup_mock_vitals(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.vitals == null:
		return


	state.vitals.set_max_hp(
		MOCK_MAX_HP
	)

	state.vitals.set_hp(
		MOCK_MAX_HP
	)


	state.vitals.set_max_mp(
		MOCK_MAX_MP
	)

	state.vitals.set_mp(
		MOCK_MAX_MP
	)


# =========================================================
# INVENTARIO MOCK TEMPORAL
# =========================================================

func _setup_mock_inventory(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.inventory == null:
		return


	var sword_definition := load(
		"res://features/items/definitions/catalog/bronze_sword.tres"
	) as ItemDefinition

	var potion_definition := load(
		"res://features/items/definitions/catalog/health_potion.tres"
	) as ItemDefinition


	# -----------------------------------------------------
	# VALIDACIÓN
	# -----------------------------------------------------

	if sword_definition == null:
		print(
			"ERROR: no se pudo cargar bronze_sword.tres"
		)


	if potion_definition == null:
		print(
			"ERROR: no se pudo cargar health_potion.tres"
		)


	if (
		sword_definition == null
		or
		potion_definition == null
	):
		return


	# -----------------------------------------------------
	# ITEMS MOCK
	#
	# Conservamos exactamente la distribución que tenía
	# InventoryGrid como datos temporales.
	# -----------------------------------------------------

	state.inventory.create_item(
		potion_definition,
		40,
		Vector2i(
			6,
			3
		),
		"debug_potion_b"
	)


	state.inventory.create_item(
		sword_definition,
		1,
		Vector2i(
			2,
			1
		),
		"debug_sword_a"
	)


	state.inventory.create_item(
		sword_definition,
		1,
		Vector2i(
			4,
			2
		),
		"debug_sword_b"
	)


	state.inventory.create_item(
		potion_definition,
		25,
		Vector2i(
			6,
			1
		),
		"debug_potion_a"
	)


# =========================================================
# SKILLS MOCK TEMPORALES
# =========================================================

func _setup_mock_skills(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.skill_book == null:
		return


	if state.skill_hotbar == null:
		return


	var fire_ball := load(
		"res://features/skills/definitions/catalog/fire_ball.tres"
	) as SkillDefinition

	var poison := load(
		"res://features/skills/definitions/catalog/poison.tres"
	) as SkillDefinition

	var heal := load(
		"res://features/skills/definitions/catalog/heal.tres"
	) as SkillDefinition


	# -----------------------------------------------------
	# VALIDACIÓN
	# -----------------------------------------------------

	if fire_ball == null:
		print(
			"ERROR: no se pudo cargar fire_ball.tres"
		)


	if poison == null:
		print(
			"ERROR: no se pudo cargar poison.tres"
		)


	if heal == null:
		print(
			"ERROR: no se pudo cargar heal.tres"
		)


	if (
		fire_ball == null
		or
		poison == null
		or
		heal == null
	):
		return


	# -----------------------------------------------------
	# SKILL BOOK
	# -----------------------------------------------------

	state.skill_book.learn_skill(
		fire_ball
	)

	state.skill_book.learn_skill(
		poison
	)

	state.skill_book.learn_skill(
		heal
	)


	# -----------------------------------------------------
	# HOTBAR
	#
	# índice 0 → tecla 1
	# índice 1 → tecla 2
	# índice 2 → tecla 3
	# -----------------------------------------------------

	state.skill_hotbar.set_skill(
		0,
		fire_ball
	)

	state.skill_hotbar.set_skill(
		1,
		poison
	)

	state.skill_hotbar.set_skill(
		2,
		heal
	)


# =========================================================
# SALIR DEL MUNDO
# =========================================================

func end_session() -> void:
	active_character_id = -1

	active_player_state = null


	session_ended.emit()
