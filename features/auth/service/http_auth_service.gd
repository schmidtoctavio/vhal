class_name HttpAuthService
extends AuthService


# =========================================================
# CONFIGURACIÓN
# =========================================================

const API_BASE_URL: String = (
	"http://127.0.0.1:8080"
)


# =========================================================
# HTTP
# =========================================================

var _http_request: HTTPRequest = null

var _request_in_flight: bool = false

var _logout_http_request: HTTPRequest = null

var _logout_in_flight: bool = false

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
		"AuthHttpRequest"
	)


	request_owner.add_child(
		_http_request
	)
	
	_logout_http_request = HTTPRequest.new()

	_logout_http_request.name = (
		"LogoutHttpRequest"
	)


	request_owner.add_child(
		_logout_http_request
	)


	if not _logout_http_request.request_completed.is_connected(
		_on_logout_request_completed
	):
		_logout_http_request.request_completed.connect(
			_on_logout_request_completed
		)


	if not _http_request.request_completed.is_connected(
		_on_request_completed
	):
		_http_request.request_completed.connect(
			_on_request_completed
		)


# =========================================================
# LOGIN
# =========================================================

func login(
	account: String,
	password: String
) -> void:
	if _request_in_flight:
		return


	if _http_request == null:
		login_failed.emit(
			"El servicio de autenticación no está disponible."
		)

		return


	var normalized_account := (
		account.strip_edges()
	)


	if normalized_account.is_empty():
		login_failed.emit(
			"Ingresá tu cuenta."
		)

		return


	if password.is_empty():
		login_failed.emit(
			"Ingresá tu contraseña."
		)

		return


	var payload := {
		"account": normalized_account,
		"password": password,
	}


	var headers := PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json",
	])


	_request_in_flight = true


	var request_error := _http_request.request(
		API_BASE_URL + "/api/auth/login",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(
			payload
		)
	)


	if request_error != OK:
		_request_in_flight = false


		login_failed.emit(
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


	# -----------------------------------------------------
	# ERROR DE RED
	# -----------------------------------------------------

	if result != HTTPRequest.RESULT_SUCCESS:
		login_failed.emit(
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
		login_failed.emit(
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
		var message := String(
			response.get(
				"message",
				"No se pudo iniciar sesión."
			)
		)


		if message.is_empty():
			message = (
				"No se pudo iniciar sesión."
			)


		login_failed.emit(
			message
		)

		return


	# -----------------------------------------------------
	# DATA
	# -----------------------------------------------------

	var data: Dictionary = response.get(
		"data",
		{}
	)


	var account_data: Dictionary = data.get(
		"account",
		{}
	)


	var account_id := int(
		account_data.get(
			"id",
			-1
		)
	)


	var account_name := String(
		account_data.get(
			"username",
			""
		)
	)


	var access_token := String(
		data.get(
			"access_token",
			""
		)
	)


	var expires_at := String(
		data.get(
			"expires_at",
			""
		)
	)


	if (
		account_id < 0
		or
		account_name.is_empty()
		or
		access_token.is_empty()
	):
		login_failed.emit(
			"La respuesta de autenticación está incompleta."
		)

		return


	login_succeeded.emit(
		account_id,
		account_name,
		access_token,
		expires_at
	)

# =========================================================
# LOGOUT
# =========================================================

func logout(
	access_token: String
) -> void:
	if _logout_in_flight:
		return


	if _logout_http_request == null:
		logout_failed.emit(
			"El servicio de autenticación no está disponible."
		)

		return


	var normalized_token := (
		access_token.strip_edges()
	)


	if normalized_token.is_empty():
		logout_succeeded.emit()
		return


	var headers := PackedStringArray([
		"Accept: application/json",
		"Authorization: Bearer %s" % normalized_token,
	])


	_logout_in_flight = true


	var request_error := (
		_logout_http_request.request(
			API_BASE_URL + "/api/auth/logout",
			headers,
			HTTPClient.METHOD_POST
		)
	)


	if request_error != OK:
		_logout_in_flight = false


		logout_failed.emit(
			"No se pudo iniciar el cierre de sesión."
		)


# =========================================================
# RESPUESTA DE LOGOUT
# =========================================================

func _on_logout_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray
) -> void:
	_logout_in_flight = false


	if result != HTTPRequest.RESULT_SUCCESS:
		logout_failed.emit(
			"No se pudo conectar con el servidor para cerrar sesión."
		)

		return


	# -----------------------------------------------------
	# 401 = el token ya no es válido.
	#
	# Desde el punto de vista del cliente, igualmente
	# podemos considerar la sesión cerrada.
	# -----------------------------------------------------

	if response_code == 401:
		logout_succeeded.emit()
		return


	if (
		response_code < 200
		or
		response_code >= 300
	):
		logout_failed.emit(
			"No se pudo cerrar la sesión."
		)

		return


	logout_succeeded.emit()
