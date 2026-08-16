class_name MockCharacterService
extends CharacterService


# =========================================================
# ESTADO MOCK
# =========================================================

var _characters: Array[CharacterSummary] = []

var _next_character_id: int = (
	DebugCharacterFactory.FIRST_DYNAMIC_CHARACTER_ID
)


# =========================================================
# CARGAR PERSONAJES
# =========================================================

func load_characters(
	_account_id: int
) -> void:
	_characters = (
		DebugCharacterFactory.create_default_roster()
	)


	_next_character_id = (
		DebugCharacterFactory.FIRST_DYNAMIC_CHARACTER_ID
	)


	characters_loaded.emit(
		_copy_characters()
	)


# =========================================================
# CREAR PERSONAJE
# =========================================================

func create_character(
	_account_id: int,
	slot_index: int,
	character_name: String,
	character_class: CharacterClassDefinition
) -> void:
	if character_class == null:
		request_failed.emit(
			"La clase seleccionada no es válida."
		)

		return


	if slot_index < 0:
		request_failed.emit(
			"El slot seleccionado no es válido."
		)

		return


	if slot_index >= _characters.size():
		request_failed.emit(
			"El slot seleccionado no es válido."
		)

		return


	if _characters[
		slot_index
	] != null:
		request_failed.emit(
			"El slot ya está ocupado."
		)

		return


	var normalized_name := (
		character_name.strip_edges()
	)


	if normalized_name.is_empty():
		request_failed.emit(
			"El nombre del personaje no puede estar vacío."
		)

		return


	var new_character := CharacterSummary.new(
		_next_character_id,
		normalized_name,
		character_class.display_name,
		1,
		slot_index
	)


	_next_character_id += 1


	_characters[
		slot_index
	] = new_character


	# Primero actualizamos el listado.
	characters_loaded.emit(
		_copy_characters()
	)


	# Luego informamos qué personaje fue creado.
	character_created.emit(
		new_character
	)


# =========================================================
# ELIMINAR PERSONAJE
# =========================================================

func delete_character(
	_account_id: int,
	character_id: int
) -> void:
	for slot_index in range(
		_characters.size()
	):
		var character := (
			_characters[
				slot_index
			]
		)


		if character == null:
			continue


		if character.character_id != character_id:
			continue


		_characters[
			slot_index
		] = null


		characters_loaded.emit(
			_copy_characters()
		)


		character_deleted.emit(
			character_id,
			slot_index
		)


		return


	request_failed.emit(
		"No se encontró el personaje."
	)


# =========================================================
# COPIA SEGURA
# =========================================================

func _copy_characters() -> Array[CharacterSummary]:
	var result: Array[CharacterSummary] = []


	result.assign(
		_characters
	)


	return result
