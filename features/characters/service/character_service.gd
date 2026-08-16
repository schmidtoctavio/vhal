class_name CharacterService
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

@warning_ignore("unused_signal")
signal characters_loaded(
	characters: Array[CharacterSummary]
)

@warning_ignore("unused_signal")
signal character_created(
	character: CharacterSummary
)

@warning_ignore("unused_signal")
signal character_deleted(
	character_id: int,
	slot_index: int
)

@warning_ignore("unused_signal")
signal request_failed(
	message: String
)


# =========================================================
# CARGAR PERSONAJES
# =========================================================

func load_characters(
	_account_id: int
) -> void:
	push_error(
		"CharacterService.load_characters() debe ser implementado."
	)


# =========================================================
# CREAR PERSONAJE
# =========================================================

func create_character(
	_account_id: int,
	_slot_index: int,
	_character_name: String,
	_character_class: CharacterClassDefinition
) -> void:
	push_error(
		"CharacterService.create_character() debe ser implementado."
	)


# =========================================================
# ELIMINAR PERSONAJE
# =========================================================

func delete_character(
	_account_id: int,
	_character_id: int
) -> void:
	push_error(
		"CharacterService.delete_character() debe ser implementado."
	)
