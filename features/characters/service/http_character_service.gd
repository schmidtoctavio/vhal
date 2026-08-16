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
	_slot_index: int,
	_character_name: String,
	_character_class: CharacterClassDefinition
) -> void:
	request_failed.emit(
		"La creación de personajes todavía no está conectada al servidor."
	)


func delete_character(
	_account_id: int,
	_character_id: int
) -> void:
	request_failed.emit(
		"La eliminación de personajes todavía no está conectada al servidor."
	)
