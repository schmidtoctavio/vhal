class_name GameServerClient
extends Node


# =========================================================
# SIGNALS
# =========================================================

signal game_server_connected(
	peer_id: int
)

signal game_server_connection_failed(
	message: String
)

signal game_server_disconnected


# =========================================================
# CONFIGURACIÓN
# =========================================================

const DEFAULT_HOST: String = "127.0.0.1"

const DEFAULT_PORT: int = 7000

const SERVER_PEER_ID: int = 1

const AUTH_TIMEOUT_SECONDS: float = 10.0


# =========================================================
# ESTADO
# =========================================================

var network_peer: ENetMultiplayerPeer = null

var connecting: bool = false

var connected: bool = false

var pending_ticket: String = ""

var _failure_emitted: bool = false


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_connect_multiplayer_signals()


# =========================================================
# SIGNALS MULTIPLAYER
# =========================================================

func _connect_multiplayer_signals() -> void:
	if not multiplayer.connected_to_server.is_connected(
		_on_connected_to_server
	):
		multiplayer.connected_to_server.connect(
			_on_connected_to_server
		)


	if not multiplayer.connection_failed.is_connected(
		_on_connection_failed
	):
		multiplayer.connection_failed.connect(
			_on_connection_failed
		)


	if not multiplayer.server_disconnected.is_connected(
		_on_server_disconnected
	):
		multiplayer.server_disconnected.connect(
			_on_server_disconnected
		)


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer == null:
		return


	if not scene_multiplayer.peer_authenticating.is_connected(
		_on_peer_authenticating
	):
		scene_multiplayer.peer_authenticating.connect(
			_on_peer_authenticating
		)


	if not scene_multiplayer.peer_authentication_failed.is_connected(
		_on_peer_authentication_failed
	):
		scene_multiplayer.peer_authentication_failed.connect(
			_on_peer_authentication_failed
		)


# =========================================================
# CONECTAR
# =========================================================

func connect_to_game_server(
	ticket: String,
	host: String = DEFAULT_HOST,
	port: int = DEFAULT_PORT
) -> Error:
	if connecting or connected:
		return ERR_ALREADY_IN_USE


	var normalized_ticket := (
		ticket.strip_edges()
	)


	if normalized_ticket.length() != 64:
		return ERR_INVALID_PARAMETER


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer == null:
		return ERR_UNAVAILABLE


	network_peer = ENetMultiplayerPeer.new()


	var result := network_peer.create_client(
		host,
		port
	)


	if result != OK:
		network_peer = null

		return result


	pending_ticket = normalized_ticket

	connecting = true

	connected = false

	_failure_emitted = false


	multiplayer.multiplayer_peer = (
		network_peer
	)


	scene_multiplayer.auth_timeout = (
		AUTH_TIMEOUT_SECONDS
	)


	scene_multiplayer.auth_callback = (
		_on_auth_payload_received
	)


	print(
		"GameServerClient | Conectando a ",
		host,
		":",
		port,
		"..."
	)


	return OK


# =========================================================
# AUTHENTICATING
# =========================================================

func _on_peer_authenticating(
	peer_id: int
) -> void:
	if not connecting:
		return


	if peer_id != SERVER_PEER_ID:
		_fail_connection(
			"Se recibió un peer de autenticación inválido."
		)

		return


	if pending_ticket.length() != 64:
		_fail_connection(
			"No existe un ticket de entrada válido."
		)

		return


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer == null:
		_fail_connection(
			"SceneMultiplayer no está disponible."
		)

		return


	var payload := JSON.stringify({
		"ticket": pending_ticket,
	}).to_utf8_buffer()


	var send_result := (
		scene_multiplayer.send_auth(
			peer_id,
			payload
		)
	)


	if send_result != OK:
		_fail_connection(
			"No se pudo enviar la credencial al Game Server."
		)

		return


	var complete_result := (
		scene_multiplayer.complete_auth(
			peer_id
		)
	)


	if complete_result != OK:
		_fail_connection(
			"No se pudo completar la autenticación local."
		)

		return


	print(
		"GameServerClient | Credencial de sesión enviada."
	)


# =========================================================
# AUTH CALLBACK
# =========================================================

func _on_auth_payload_received(
	_peer_id: int,
	_payload: PackedByteArray
) -> void:
	# -----------------------------------------------------
	# El servidor no necesita enviarnos credenciales.
	#
	# El callback debe existir para que SceneMultiplayer
	# habilite el estado de autenticación en este cliente.
	# -----------------------------------------------------

	pass


# =========================================================
# AUTH FALLIDA
# =========================================================

func _on_peer_authentication_failed(
	peer_id: int
) -> void:
	if peer_id != SERVER_PEER_ID:
		return


	if not connecting:
		return


	_fail_connection(
		"El Game Server rechazó la autenticación."
	)


# =========================================================
# CONECTADO
# =========================================================

func _on_connected_to_server() -> void:
	connecting = false

	connected = true

	pending_ticket = ""

	_failure_emitted = false


	var peer_id := (
		multiplayer.get_unique_id()
	)


	print(
		"GameServerClient | Autenticado | Peer ID: ",
		peer_id
	)


	game_server_connected.emit(
		peer_id
	)


# =========================================================
# ERROR DE CONEXIÓN
# =========================================================

func _on_connection_failed() -> void:
	if _failure_emitted:
		return


	_fail_connection(
		"No se pudo conectar al Game Server."
	)


# =========================================================
# SERVIDOR DESCONECTADO
# =========================================================

func _on_server_disconnected() -> void:
	if _failure_emitted:
		return


	var had_connection := (
		connecting
		or
		connected
	)


	_reset_connection_state()


	if not had_connection:
		return


	print(
		"GameServerClient | Game Server desconectado."
	)


	game_server_disconnected.emit()


# =========================================================
# FALLAR CONEXIÓN
# =========================================================

func _fail_connection(
	message: String
) -> void:
	if _failure_emitted:
		return


	_failure_emitted = true


	print(
		"GameServerClient | ",
		message
	)


	_reset_connection_state()


	game_server_connection_failed.emit(
		message
	)


# =========================================================
# DESCONECTAR
# =========================================================

func disconnect_from_game_server() -> void:
	_failure_emitted = false


	_reset_connection_state()


# =========================================================
# RESET
# =========================================================

func _reset_connection_state() -> void:
	connecting = false

	connected = false

	pending_ticket = ""


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer != null:
		scene_multiplayer.auth_callback = (
			Callable()
		)


	if network_peer != null:
		network_peer.close()


	network_peer = null


	multiplayer.multiplayer_peer = (
		OfflineMultiplayerPeer.new()
	)
