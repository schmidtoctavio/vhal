class_name HttpGameSessionTicketService
extends GameSessionTicketService


# =========================================================
# CONFIGURACIÓN
# =========================================================

const API_BASE_URL: String = (
	"http://127.0.0.1:8080"
)

const TICKET_PATH: String = (
	"/api/game-session/tickets"
)


# =========================================================
# HTTP
# =========================================================

var _http_request: HTTPRequest = null

var _request_in_flight: bool = false

var _pending_character_id: int = -1


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
		"GameSessionTicketHttpRequest"
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
# PEDIR TICKET
# =========================================================

func issue_ticket(
	character_id: int
) -> void:
	if _request_in_flight:
		return


	if _http_request == null:
		ticket_failed.emit(
			"El servicio de sesión no está disponible."
		)

		return


	if not ClientSession.authenticated:
		ticket_failed.emit(
			"No hay una sesión autenticada."
		)

		return


	if character_id <= 0:
		ticket_failed.emit(
			"El personaje seleccionado no es válido."
		)

		return


	var access_token := (
		ClientSession.access_token.strip_edges()
	)


	if access_token.is_empty():
		ticket_failed.emit(
			"La sesión no posee un token válido."
		)

		return


	var payload := {
		"character_id": character_id,
	}


	var headers := PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: Bearer %s" % access_token,
	])


	_pending_character_id = character_id

	_request_in_flight = true


	var request_error := (
		_http_request.request(
			API_BASE_URL
			+
			TICKET_PATH,
			headers,
			HTTPClient.METHOD_POST,
			JSON.stringify(
				payload
			)
		)
	)


	if request_error != OK:
		_request_in_flight = false

		_pending_character_id = -1


		ticket_failed.emit(
			"No se pudo solicitar el ticket de entrada."
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
	var expected_character_id := (
		_pending_character_id
	)


	_request_in_flight = false

	_pending_character_id = -1


	if result != HTTPRequest.RESULT_SUCCESS:
		ticket_failed.emit(
			"No se pudo conectar con el servidor de autenticación."
		)

		return


	var parsed: Variant = (
		JSON.parse_string(
			body.get_string_from_utf8()
		)
	)


	if typeof(parsed) != TYPE_DICTIONARY:
		ticket_failed.emit(
			"El servidor devolvió una respuesta inválida."
		)

		return


	var response: Dictionary = (
		parsed
	)


	if (
		response_code < 200
		or
		response_code >= 300
	):
		if response_code == 401:
			ticket_failed.emit(
				"La sesión expiró o ya no es válida."
			)

			return


		var message := String(
			response.get(
				"message",
				"No se pudo obtener el ticket de entrada."
			)
		)


		ticket_failed.emit(
			message
		)

		return


	var data_value: Variant = (
		response.get(
			"data",
			null
		)
	)


	if typeof(data_value) != TYPE_DICTIONARY:
		ticket_failed.emit(
			"La respuesta no contiene los datos del ticket."
		)

		return


	var data: Dictionary = (
		data_value
	)


	var ticket := String(
		data.get(
			"ticket",
			""
		)
	)


	var character_id := int(
		data.get(
			"character_id",
			-1
		)
	)


	var expires_at := String(
		data.get(
			"expires_at",
			""
		)
	)


	if ticket.length() != 64:
		ticket_failed.emit(
			"El servidor devolvió un ticket inválido."
		)

		return


	if (
		character_id
		!=
		expected_character_id
	):
		ticket_failed.emit(
			"El ticket no corresponde al personaje solicitado."
		)

		return


	if expires_at.is_empty():
		ticket_failed.emit(
			"El ticket no posee una expiración válida."
		)

		return


	ticket_issued.emit(
		ticket,
		character_id,
		expires_at
	)
