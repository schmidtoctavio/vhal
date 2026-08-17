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


# =========================================================
# ESTADO
# =========================================================

var network_peer: ENetMultiplayerPeer = null

var connecting: bool = false

var connected: bool = false


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_connect_multiplayer_signals()


# =========================================================
# SIGNALS DE MULTIPLAYER
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


# =========================================================
# CONECTAR
# =========================================================

func connect_to_game_server(
	host: String = DEFAULT_HOST,
	port: int = DEFAULT_PORT
) -> Error:
	if connecting or connected:
		return ERR_ALREADY_IN_USE


	network_peer = ENetMultiplayerPeer.new()


	var result := network_peer.create_client(
		host,
		port
	)


	if result != OK:
		network_peer = null


		return result


	connecting = true


	multiplayer.multiplayer_peer = (
		network_peer
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
# DESCONECTAR
# =========================================================

func disconnect_from_game_server() -> void:
	connecting = false

	connected = false

	network_peer = null


	multiplayer.multiplayer_peer = (
		OfflineMultiplayerPeer.new()
	)


# =========================================================
# CONECTADO
# =========================================================

func _on_connected_to_server() -> void:
	connecting = false

	connected = true


	var peer_id := (
		multiplayer.get_unique_id()
	)


	print(
		"GameServerClient | Conectado | Peer ID: ",
		peer_id
	)


	game_server_connected.emit(
		peer_id
	)


# =========================================================
# ERROR DE CONEXIÓN
# =========================================================

func _on_connection_failed() -> void:
	connecting = false

	connected = false

	network_peer = null


	multiplayer.multiplayer_peer = (
		OfflineMultiplayerPeer.new()
	)


	var message := (
		"No se pudo conectar al Game Server."
	)


	print(
		"GameServerClient | ",
		message
	)


	game_server_connection_failed.emit(
		message
	)


# =========================================================
# SERVIDOR DESCONECTADO
# =========================================================

func _on_server_disconnected() -> void:
	connecting = false

	connected = false

	network_peer = null


	multiplayer.multiplayer_peer = (
		OfflineMultiplayerPeer.new()
	)


	print(
		"GameServerClient | Game Server desconectado."
	)


	game_server_disconnected.emit()
