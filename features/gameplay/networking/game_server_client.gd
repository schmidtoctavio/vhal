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

signal world_snapshot_received(
	snapshot: Dictionary
)

signal authoritative_movement_state_received(
	position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
)

# =========================================================
# CONFIGURACIÓN
# =========================================================

const DEFAULT_HOST: String = "127.0.0.1"

const DEFAULT_PORT: int = 7000

const SERVER_PEER_ID: int = 1

const AUTH_TIMEOUT_SECONDS: float = 10.0

const NETWORK_PROTOCOL_VERSION: int = 1

const MESSAGE_WORLD_SNAPSHOT: String = (
	"world_snapshot"
)

const MESSAGE_MOVE_REQUEST: String = (
	"move_request"
)

const MESSAGE_MOVEMENT_STATE: String = (
	"movement_state"
)

# =========================================================
# ESTADO
# =========================================================

var network_peer: ENetMultiplayerPeer = null

var connecting: bool = false

var connected: bool = false

var pending_ticket: String = ""

var _failure_emitted: bool = false

var latest_world_snapshot: Dictionary = {}

var latest_movement_sequence: int = 0

var latest_authoritative_position: Vector3 = (
	Vector3.ZERO
)

var latest_authoritative_rotation_y: float = 0.0

var latest_authoritative_moving: bool = false

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

	if not scene_multiplayer.peer_packet.is_connected(
		_on_peer_packet
	):
		scene_multiplayer.peer_packet.connect(
			_on_peer_packet
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
# PAQUETES DEL GAME SERVER
# =========================================================

func _on_peer_packet(
	peer_id: int,
	packet: PackedByteArray
) -> void:
	if peer_id != SERVER_PEER_ID:
		_fail_connection(
			"Se recibió información desde un peer inválido."
		)

		return


	if not connected:
		return


	var parsed: Variant = (
		JSON.parse_string(
			packet.get_string_from_utf8()
		)
	)


	if typeof(parsed) != TYPE_DICTIONARY:
		_fail_connection(
			"El Game Server envió un paquete inválido."
		)

		return


	var message: Dictionary = (
		parsed
	)


	var version := int(
		message.get(
			"version",
			0
		)
	)


	if version != NETWORK_PROTOCOL_VERSION:
		_fail_connection(
			"Versión de protocolo incompatible."
		)

		return


	var message_type := String(
		message.get(
			"type",
			""
		)
	)


	if message_type == MESSAGE_WORLD_SNAPSHOT:
		var data_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(data_value) != TYPE_DICTIONARY:
			_fail_connection(
				"El snapshot de mundo es inválido."
			)

			return


		var snapshot: Dictionary = (
			data_value
		)


		_process_world_snapshot(
			snapshot
		)


		return


	if message_type == MESSAGE_MOVEMENT_STATE:
		var movement_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(movement_value) != TYPE_DICTIONARY:
			return


		_process_movement_state(
			movement_value
		)


		return


# =========================================================
# SNAPSHOT DE MUNDO
# =========================================================

func _process_world_snapshot(
	snapshot: Dictionary
) -> void:
	var snapshot_peer_id := int(
		snapshot.get(
			"peer_id",
			-1
		)
	)


	var local_peer_id := (
		multiplayer.get_unique_id()
	)


	if snapshot_peer_id != local_peer_id:
		_fail_connection(
			"El snapshot pertenece a otro peer."
		)

		return


	var account_id := int(
		snapshot.get(
			"account_id",
			-1
		)
	)


	if account_id <= 0:
		_fail_connection(
			"El snapshot no posee una cuenta válida."
		)

		return


	var character_value: Variant = (
		snapshot.get(
			"character",
			null
		)
	)


	if typeof(character_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee un personaje válido."
		)

		return


	var character_data: Dictionary = (
		character_value
	)


	var character_id := int(
		character_data.get(
			"id",
			-1
		)
	)


	if character_id <= 0:
		_fail_connection(
			"El snapshot posee un Character ID inválido."
		)

		return


	var world_value: Variant = (
		snapshot.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee datos de mundo."
		)

		return


	var world_data: Dictionary = (
		world_value
	)


	var map_id := String(
		world_data.get(
			"map_id",
			""
		)
	).strip_edges()


	if map_id.is_empty():
		_fail_connection(
			"El snapshot no posee un mapa válido."
		)

		return


	var position_value: Variant = (
		world_data.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee una posición válida."
		)

		return


	var position_data: Dictionary = (
		position_value
	)


	if (
		not position_data.has("x")
		or
		not position_data.has("y")
		or
		not position_data.has("z")
	):
		_fail_connection(
			"La posición del snapshot está incompleta."
		)

		return


	var position := Vector3(
		float(
			position_data["x"]
		),
		float(
			position_data["y"]
		),
		float(
			position_data["z"]
		)
	)


	var rotation_y := float(
		world_data.get(
			"rotation_y",
			0.0
		)
	)


	latest_world_snapshot = {
		"peer_id": snapshot_peer_id,

		"account_id": account_id,

		"character": character_data.duplicate(
			true
		),

		"world": {
			"map_id": map_id,

			"position": {
				"x": position.x,
				"y": position.y,
				"z": position.z,
			},

			"rotation_y": rotation_y,
		},
	}


	print(
		"GameServerClient | Snapshot autoritativo recibido",
		" | Character ID: ",
		character_id,
		" | Mapa: ",
		map_id,
		" | Posición: ",
		position
	)


	world_snapshot_received.emit(
		latest_world_snapshot.duplicate(
			true
		)
	)

# =========================================================
# ESTADO AUTORITATIVO DE MOVIMIENTO
# =========================================================

func _process_movement_state(
	data: Dictionary
) -> void:
	var state_peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	var local_peer_id := (
		multiplayer.get_unique_id()
	)


	if state_peer_id != local_peer_id:
		return


	var sequence := int(
		data.get(
			"sequence",
			0
		)
	)


	if sequence <= latest_movement_sequence:
		return


	var position_value: Variant = (
		data.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		return


	var position_data: Dictionary = (
		position_value
	)


	if (
		not position_data.has("x")
		or
		not position_data.has("y")
		or
		not position_data.has("z")
	):
		return


	var position := Vector3(
		float(
			position_data["x"]
		),
		float(
			position_data["y"]
		),
		float(
			position_data["z"]
		)
	)


	var rotation_y := float(
		data.get(
			"rotation_y",
			0.0
		)
	)


	var moving := bool(
		data.get(
			"moving",
			false
		)
	)


	latest_movement_sequence = sequence

	latest_authoritative_position = position

	latest_authoritative_rotation_y = rotation_y

	latest_authoritative_moving = moving


	print(
		"GameServerClient | Movimiento autoritativo recibido",
		" | Seq: ",
		sequence,
		" | Posición: ",
		position,
		" | Moving: ",
		moving
	)


	authoritative_movement_state_received.emit(
		position,
		rotation_y,
		moving,
		sequence
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

	latest_movement_sequence = 0

	latest_authoritative_position = Vector3.ZERO

	latest_authoritative_rotation_y = 0.0

	latest_authoritative_moving = false

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
# =========================================================
# INTENCIÓN DE MOVIMIENTO
# =========================================================

func send_move_request(
	target: Vector3
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer == null:
		return ERR_UNAVAILABLE


	var message := {
		"version": NETWORK_PROTOCOL_VERSION,

		"type": MESSAGE_MOVE_REQUEST,

		"data": {
			"target": {
				"x": target.x,
				"y": target.y,
				"z": target.z,
			},
		},
	}


	var packet := (
		JSON.stringify(
			message
		).to_utf8_buffer()
	)


	var result := (
		scene_multiplayer.send_bytes(
			packet,
			SERVER_PEER_ID,
			MultiplayerPeer.TRANSFER_MODE_RELIABLE,
			0
		)
	)


	if result == OK:
		print(
			"GameServerClient | Intención de movimiento enviada",
			" | Destino: ",
			target
		)


	return result
