class_name HttpCharacterService
extends CharacterService


# =========================================================
# CONFIGURACIÓN
# =========================================================

const API_BASE_URL: String = (
	"http://127.0.0.1:8080"
)

const CHARACTER_SLOT_COUNT: int = 5


# =========================================================
# DEFINICIONES DE CLASE
# =========================================================

const WARRIOR_CLASS: CharacterClassDefinition = preload(
	"res://features/characters/definitions/classes/warrior.tres"
)

const MAGE_CLASS: CharacterClassDefinition = preload(
	"res://features/characters/definitions/classes/mage.tres"
)

const ARCHER_CLASS: CharacterClassDefinition = preload(
	"res://features/characters/definitions/classes/archer.tres"
)


# =========================================================
# HTTP
# =========================================================

var _http_request: HTTPRequest = null

var _request_in_flight: bool = false

var _create_http_request: HTTPRequest = null

var _create_in_flight: bool = false

var _delete_http_request: HTTPRequest = null

var _delete_in_flight: bool = false

# =========================================================
# SETUP
# =========================================================

func setup(
	request_owner: Node
) -> void:
	if request_owner == null:
		return


	if _http_request != null:
		return


	_http_request = HTTPRequest.new()

	_http_request.name = (
		"CharacterHttpRequest"
	)


	request_owner.add_child(
		_http_request
	)


	if not _http_request.request_completed.is_connected(
		_on_request_completed
	):
		_http_request.request_completed.connect(
			_on_request_completed
		)
	
		_create_http_request = HTTPRequest.new()

	_create_http_request.name = (
		"CharacterCreateHttpRequest"
	)


	request_owner.add_child(
		_create_http_request
	)


	if not _create_http_request.request_completed.is_connected(
		_on_create_request_completed
	):
		_create_http_request.request_completed.connect(
			_on_create_request_completed
		)
	
		_delete_http_request = HTTPRequest.new()

	_delete_http_request.name = (
		"CharacterDeleteHttpRequest"
	)


	request_owner.add_child(
		_delete_http_request
	)


	if not _delete_http_request.request_completed.is_connected(
		_on_delete_request_completed
	):
		_delete_http_request.request_completed.connect(
			_on_delete_request_completed
		)


# =========================================================
# CARGAR PERSONAJES
# =========================================================

func load_characters(
	_account_id: int
) -> void:
	if _request_in_flight:
		return


	if _http_request == null:
		request_failed.emit(
			"El servicio de personajes no está disponible."
		)

		return


	if not ClientSession.authenticated:
		request_failed.emit(
			"No hay una sesión autenticada."
		)

		return


	var access_token := (
		ClientSession.access_token.strip_edges()
	)


	if access_token.is_empty():
		request_failed.emit(
			"La sesión no posee un token válido."
		)

		return


	var headers := PackedStringArray([
		"Accept: application/json",
		"Authorization: Bearer %s" % access_token,
	])


	_request_in_flight = true


	var request_error := _http_request.request(
		API_BASE_URL + "/api/characters",
		headers,
		HTTPClient.METHOD_GET
	)


	if request_error != OK:
		_request_in_flight = false


		request_failed.emit(
			"No se pudo iniciar la conexión con el servidor."
		)


# =========================================================
# RESPUESTA
# =========================================================

func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	_request_in_flight = false


	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit(
			"No se pudo conectar con el servidor."
		)

		return


	var body_text := (
		body.get_string_from_utf8()
	)


	var parsed: Variant = (
		JSON.parse_string(
			body_text
		)
	)


	if typeof(parsed) != TYPE_DICTIONARY:
		request_failed.emit(
			"El servidor devolvió una respuesta inválida."
		)

		return


	var response: Dictionary = parsed


	# -----------------------------------------------------
	# ERROR HTTP
	# -----------------------------------------------------

	if (
		response_code < 200
		or
		response_code >= 300
	):
		if response_code == 401:
			request_failed.emit(
				"La sesión expiró o ya no es válida."
			)

			return


		var message := String(
			response.get(
				"message",
				"No se pudieron cargar los personajes."
			)
		)


		if message.is_empty():
			message = (
				"No se pudieron cargar los personajes."
			)


		request_failed.emit(
			message
		)

		return


	# -----------------------------------------------------
	# EXTRAER DATA
	# -----------------------------------------------------

	var data: Dictionary = response.get(
		"data",
		{}
	)


	var raw_characters: Variant = data.get(
		"characters",
		[]
	)


	if typeof(raw_characters) != TYPE_ARRAY:
		request_failed.emit(
			"El servidor devolvió una lista de personajes inválida."
		)

		return


	# -----------------------------------------------------
	# ROSTER DE 5 SLOTS
	# -----------------------------------------------------

	var characters: Array[CharacterSummary] = []

	characters.resize(
		CHARACTER_SLOT_COUNT
	)


	for raw_character in raw_characters:
		if typeof(raw_character) != TYPE_DICTIONARY:
			request_failed.emit(
				"El servidor devolvió un personaje inválido."
			)

			return


		var character_data: Dictionary = (
			raw_character
		)


		var character_id := int(
			character_data.get(
				"id",
				-1
			)
		)


		var slot_index := int(
			character_data.get(
				"slot_index",
				-1
			)
		)


		var character_name := String(
			character_data.get(
				"name",
				""
			)
		)


		var class_id := String(
			character_data.get(
				"class_id",
				""
			)
		)


		var level := int(
			character_data.get(
				"level",
				1
			)
		)


		if (
			character_id < 0
			or
			slot_index < 0
			or
			slot_index >= CHARACTER_SLOT_COUNT
			or
			character_name.is_empty()
			or
			class_id.is_empty()
		):
			request_failed.emit(
				"El servidor devolvió datos de personaje incompletos."
			)

			return


		var class_definition := (
			_get_class_definition(
				class_id
			)
		)


		if class_definition == null:
			request_failed.emit(
				"Este cliente no reconoce la clase '%s'."
				% class_id
			)

			return


		characters[
			slot_index
		] = CharacterSummary.new(
			character_id,
			character_name,
			class_definition.display_name,
			level,
			slot_index,
			class_id
		)


	characters_loaded.emit(
		characters
	)


# =========================================================
# RESOLVER CLASE
# =========================================================

func _get_class_definition(
	class_id: String
) -> CharacterClassDefinition:
	match class_id:
		"warrior":
			return WARRIOR_CLASS

		"mage":
			return MAGE_CLASS

		"archer":
			return ARCHER_CLASS

		_:
			return null


# =========================================================
# F08 — MUTACIONES REALES
# =========================================================

func create_character(
	_account_id: int,
	slot_index: int,
	character_name: String,
	character_class: CharacterClassDefinition
) -> void:
	if _create_in_flight:
		return


	if _create_http_request == null:
		request_failed.emit(
			"El servicio de creación de personajes no está disponible."
		)

		return


	if not ClientSession.authenticated:
		request_failed.emit(
			"No hay una sesión autenticada."
		)

		return


	var access_token := (
		ClientSession.access_token.strip_edges()
	)


	if access_token.is_empty():
		request_failed.emit(
			"La sesión no posee un token válido."
		)

		return


	if character_class == null:
		request_failed.emit(
			"La clase seleccionada no es válida."
		)

		return


	var class_id := (
		character_class.class_id.strip_edges()
	)


	if class_id.is_empty():
		request_failed.emit(
			"La clase seleccionada no posee un ID válido."
		)

		return


	var normalized_name := (
		character_name.strip_edges()
	)


	if normalized_name.is_empty():
		request_failed.emit(
			"Ingresá un nombre para el personaje."
		)

		return


	var payload := {
		"slot_index": slot_index,
		"name": normalized_name,
		"class_id": class_id,
	}


	var headers := PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: Bearer %s" % access_token,
	])


	_create_in_flight = true


	var request_error := (
		_create_http_request.request(
			API_BASE_URL + "/api/characters",
			headers,
			HTTPClient.METHOD_POST,
			JSON.stringify(
				payload
			)
		)
	)


	if request_error != OK:
		_create_in_flight = false


		request_failed.emit(
			"No se pudo iniciar la creación del personaje."
		)

# =========================================================
# RESPUESTA DE CREACIÓN
# =========================================================

func _on_create_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	_create_in_flight = false


	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit(
			"No se pudo conectar con el servidor."
		)

		return


	var body_text := (
		body.get_string_from_utf8()
	)


	var parsed: Variant = (
		JSON.parse_string(
			body_text
		)
	)


	if typeof(parsed) != TYPE_DICTIONARY:
		request_failed.emit(
			"El servidor devolvió una respuesta inválida."
		)

		return


	var response: Dictionary = parsed


	# -----------------------------------------------------
	# ERROR HTTP
	# -----------------------------------------------------

	if (
		response_code < 200
		or
		response_code >= 300
	):
		if response_code == 401:
			request_failed.emit(
				"La sesión expiró o ya no es válida."
			)

			return


		request_failed.emit(
			_extract_error_message(
				response,
				"No se pudo crear el personaje."
			)
		)

		return


	# -----------------------------------------------------
	# PERSONAJE CREADO
	# -----------------------------------------------------

	var data: Dictionary = response.get(
		"data",
		{}
	)


	var character_data: Dictionary = data.get(
		"character",
		{}
	)


	var character_id := int(
		character_data.get(
			"id",
			-1
		)
	)


	var slot_index := int(
		character_data.get(
			"slot_index",
			-1
		)
	)


	var character_name := String(
		character_data.get(
			"name",
			""
		)
	)


	var class_id := String(
		character_data.get(
			"class_id",
			""
		)
	)


	var level := int(
		character_data.get(
			"level",
			1
		)
	)


	if (
		character_id < 0
		or
		slot_index < 0
		or
		slot_index >= CHARACTER_SLOT_COUNT
		or
		character_name.is_empty()
		or
		class_id.is_empty()
	):
		request_failed.emit(
			"El servidor devolvió datos incompletos del personaje creado."
		)

		return


	var class_definition := (
		_get_class_definition(
			class_id
		)
	)


	if class_definition == null:
		request_failed.emit(
			"Este cliente no reconoce la clase '%s'."
			% class_id
		)

		return


	var new_character := CharacterSummary.new(
		character_id,
		character_name,
		class_definition.display_name,
		level,
		slot_index,
		class_id
	)


	# -----------------------------------------------------
	# ACTUALIZAR ROSTER LOCAL
	#
	# Mantenemos el mismo orden de señales que utilizaba
	# MockCharacterService:
	#
	# 1. characters_loaded
	# 2. character_created
	# -----------------------------------------------------

	var characters: Array[CharacterSummary] = []

	characters.assign(
		ClientSession.character_summaries
	)


	if characters.size() != CHARACTER_SLOT_COUNT:
		characters.resize(
			CHARACTER_SLOT_COUNT
		)


	characters[
		slot_index
	] = new_character


	characters_loaded.emit(
		characters
	)


	character_created.emit(
		new_character
	)

# =========================================================
# MENSAJE DE ERROR API
# =========================================================

func _extract_error_message(
	response: Dictionary,
	fallback: String
) -> String:
	var errors: Variant = response.get(
		"errors",
		{}
	)


	if typeof(errors) == TYPE_DICTIONARY:
		var error_dictionary: Dictionary = errors


		for field in error_dictionary:
			var field_errors: Variant = (
				error_dictionary[field]
			)


			if (
				typeof(field_errors) == TYPE_ARRAY
				and
				not field_errors.is_empty()
			):
				return String(
					field_errors[0]
				)


	var message := String(
		response.get(
			"message",
			fallback
		)
	)


	if message.is_empty():
		return fallback


	return message

# =========================================================
# ELIMINAR PERSONAJE
# =========================================================

func delete_character(
	_account_id: int,
	character_id: int
) -> void:
	if _delete_in_flight:
		return


	if _delete_http_request == null:
		request_failed.emit(
			"El servicio de eliminación de personajes no está disponible."
		)

		return


	if not ClientSession.authenticated:
		request_failed.emit(
			"No hay una sesión autenticada."
		)

		return


	if character_id <= 0:
		request_failed.emit(
			"El personaje seleccionado no es válido."
		)

		return


	var access_token := (
		ClientSession.access_token.strip_edges()
	)


	if access_token.is_empty():
		request_failed.emit(
			"La sesión no posee un token válido."
		)

		return


	var headers := PackedStringArray([
		"Accept: application/json",
		"Authorization: Bearer %s" % access_token,
	])


	_delete_in_flight = true


	var request_error := (
		_delete_http_request.request(
			API_BASE_URL
			+ "/api/characters/%d"
			% character_id,
			headers,
			HTTPClient.METHOD_DELETE
		)
	)


	if request_error != OK:
		_delete_in_flight = false


		request_failed.emit(
			"No se pudo iniciar la eliminación del personaje."
		)

# =========================================================
# RESPUESTA DE ELIMINACIÓN
# =========================================================

func _on_delete_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	_delete_in_flight = false


	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit(
			"No se pudo conectar con el servidor."
		)

		return


	var body_text := (
		body.get_string_from_utf8()
	)


	var parsed: Variant = (
		JSON.parse_string(
			body_text
		)
	)


	if typeof(parsed) != TYPE_DICTIONARY:
		request_failed.emit(
			"El servidor devolvió una respuesta inválida."
		)

		return


	var response: Dictionary = parsed


	if (
		response_code < 200
		or
		response_code >= 300
	):
		if response_code == 401:
			request_failed.emit(
				"La sesión expiró o ya no es válida."
			)

			return


		request_failed.emit(
			_extract_error_message(
				response,
				"No se pudo eliminar el personaje."
			)
		)

		return


	var data: Dictionary = response.get(
		"data",
		{}
	)


	var character_data: Dictionary = data.get(
		"character",
		{}
	)


	var character_id := int(
		character_data.get(
			"id",
			-1
		)
	)


	var slot_index := int(
		character_data.get(
			"slot_index",
			-1
		)
	)


	if (
		character_id <= 0
		or
		slot_index < 0
		or
		slot_index >= CHARACTER_SLOT_COUNT
	):
		request_failed.emit(
			"El servidor devolvió datos inválidos del personaje eliminado."
		)

		return


	var characters: Array[CharacterSummary] = []

	characters.assign(
		ClientSession.character_summaries
	)


	if characters.size() != CHARACTER_SLOT_COUNT:
		characters.resize(
			CHARACTER_SLOT_COUNT
		)


	var current_character := (
		characters[
			slot_index
		]
	)


	if (
		current_character != null
		and
		current_character.character_id != character_id
	):
		request_failed.emit(
			"El estado local de personajes no coincide con el servidor."
		)

		return


	characters[
		slot_index
	] = null


	characters_loaded.emit(
		characters
	)


	character_deleted.emit(
		character_id,
		slot_index
	)
