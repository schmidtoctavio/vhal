extends Node


# =========================================================
# SEÑALES
# =========================================================

signal authentication_changed(
	authenticated: bool
)

signal character_summaries_changed

signal selected_character_changed(
	character_id: int,
	slot_index: int
)


# =========================================================
# CUENTA
# =========================================================

var account_id: int = -1

var account_name: String = ""

var authenticated: bool = false


# =========================================================
# PERSONAJES
# =========================================================

var character_summaries: Array[CharacterSummary] = []

var selected_character_id: int = -1

var selected_character_slot: int = -1


# =========================================================
# AUTENTICACIÓN
# =========================================================

func authenticate(
	new_account_id: int,
	new_account_name: String
) -> void:
	account_id = new_account_id

	account_name = new_account_name.strip_edges()

	authenticated = true


	authentication_changed.emit(
		authenticated
	)


# =========================================================
# PERSONAJES DE LA CUENTA
# =========================================================

func set_character_summaries(
	summaries: Array[CharacterSummary]
) -> void:
	character_summaries.clear()


	for summary in summaries:
		character_summaries.append(
			summary
		)


	character_summaries_changed.emit()


# =========================================================
# SELECCIÓN DE PERSONAJE
# =========================================================

func select_character(
	character: CharacterSummary
) -> void:
	if character == null:
		clear_character_selection()
		return


	selected_character_id = (
		character.character_id
	)

	selected_character_slot = (
		character.slot_index
	)


	selected_character_changed.emit(
		selected_character_id,
		selected_character_slot
	)


func clear_character_selection() -> void:
	selected_character_id = -1

	selected_character_slot = -1


	selected_character_changed.emit(
		selected_character_id,
		selected_character_slot
	)


# =========================================================
# CERRAR SESIÓN
# =========================================================

func clear_session() -> void:
	account_id = -1

	account_name = ""

	authenticated = false


	character_summaries.clear()


	selected_character_id = -1

	selected_character_slot = -1


	authentication_changed.emit(
		authenticated
	)

	character_summaries_changed.emit()

	selected_character_changed.emit(
		selected_character_id,
		selected_character_slot
	)
