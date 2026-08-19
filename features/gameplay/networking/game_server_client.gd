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

signal remote_player_movement_state_received(
	peer_id: int,
	position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
)

signal npc_interaction_decision_received(
	request_id: int,
	accepted: bool,
	npc_id: String,
	service_id: String,
	reason: String
)

signal movement_decision_received(
	request_id: int,
	accepted: bool,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	authorized_target: Vector3,
	reason: String
)

signal world_presence_snapshot_received(
	players: Array
)

signal remote_player_joined(
	player: Dictionary
)

signal remote_player_left(
	peer_id: int
)

signal npc_service_ended_received(
	npc_id: String,
	service_id: String,
	reason: String
)

signal vault_snapshot_received(
	snapshot: Dictionary
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

const MESSAGE_NPC_INTERACTION_REQUEST: String = (
	"npc_interaction_request"
)

const MESSAGE_MOVEMENT_STATE: String = (
	"movement_state"
)

const MESSAGE_MOVEMENT_DECISION: String = (
	"movement_decision"
)

const MESSAGE_WORLD_PRESENCE_SNAPSHOT: String = (
	"world_presence_snapshot"
)

const MESSAGE_PLAYER_PRESENCE_JOINED: String = (
	"player_presence_joined"
)

const MESSAGE_PLAYER_PRESENCE_LEFT: String = (
	"player_presence_left"
)

const MESSAGE_NPC_INTERACTION_DECISION: String = (
	"npc_interaction_decision"
)

const MESSAGE_NPC_SERVICE_END_REQUEST: String = (
	"npc_service_end_request"
)

const MESSAGE_NPC_SERVICE_ENDED: String = (
	"npc_service_ended"
)

const MESSAGE_VAULT_SNAPSHOT: String = (
	"vault_snapshot"
)

const MESSAGE_VAULT_ITEM_MOVE_REQUEST: String = (
	"vault_item_move_request"
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

var next_move_request_id: int = 1

var latest_move_request_id: int = 0

var next_npc_interaction_request_id: int = 1

var latest_npc_interaction_request_id: int = 0

var remote_players: Dictionary = {}

var remote_movement_sequences: Dictionary = {}

var next_vault_item_move_request_id: int = 1

var vault_item_move_request_pending: bool = false

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


	if message_type == MESSAGE_MOVEMENT_DECISION:
		var decision_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(decision_value) != TYPE_DICTIONARY:
			return


		_process_movement_decision(
			decision_value
		)


		return

	if message_type == MESSAGE_WORLD_PRESENCE_SNAPSHOT:
		var presence_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(presence_value) != TYPE_DICTIONARY:
			return


		_process_world_presence_snapshot(
			presence_value
		)


		return


	if message_type == MESSAGE_PLAYER_PRESENCE_JOINED:
		var joined_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(joined_value) != TYPE_DICTIONARY:
			return


		_process_player_presence_joined(
			joined_value
		)


		return


	if message_type == MESSAGE_PLAYER_PRESENCE_LEFT:
		var left_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(left_value) != TYPE_DICTIONARY:
			return


		_process_player_presence_left(
			left_value
		)


		return

	if message_type == MESSAGE_NPC_INTERACTION_DECISION:
		var decision_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(decision_value) != TYPE_DICTIONARY:
			return


		_process_npc_interaction_decision(
			decision_value
		)


		return

	if message_type == MESSAGE_NPC_SERVICE_ENDED:
		var service_end_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(service_end_value) != TYPE_DICTIONARY:
			return


		_process_npc_service_ended(
			service_end_value
		)


		return

	if message_type == MESSAGE_VAULT_SNAPSHOT:
		var vault_value: Variant = (
			message.get(
				"data",
				null
			)
		)


		if typeof(vault_value) != TYPE_DICTIONARY:
			return


		_process_vault_snapshot(
			vault_value
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


	if state_peer_id <= 1:
		return


	var sequence := int(
		data.get(
			"sequence",
			0
		)
	)


	if sequence <= 0:
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


	var authoritative_position := Vector3(
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


	var authoritative_rotation_y := float(
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


	var local_peer_id := (
		multiplayer.get_unique_id()
	)


	# -----------------------------------------------------
	# PLAYER LOCAL
	# -----------------------------------------------------

	if state_peer_id == local_peer_id:
		if sequence <= latest_movement_sequence:
			return


		latest_movement_sequence = sequence

		latest_authoritative_position = (
			authoritative_position
		)

		latest_authoritative_rotation_y = (
			authoritative_rotation_y
		)

		latest_authoritative_moving = moving


		print(
			"GameServerClient | Movimiento autoritativo recibido",
			" | Seq: ",
			sequence,
			" | Posición: ",
			authoritative_position,
			" | Moving: ",
			moving
		)


		authoritative_movement_state_received.emit(
			authoritative_position,
			authoritative_rotation_y,
			moving,
			sequence
		)


		return


	# -----------------------------------------------------
	# PLAYER REMOTO
	# -----------------------------------------------------

	if not remote_players.has(
		state_peer_id
	):
		return


	var previous_sequence := int(
		remote_movement_sequences.get(
			state_peer_id,
			0
		)
	)


	if sequence <= previous_sequence:
		return


	remote_movement_sequences[
		state_peer_id
	] = sequence


	# -----------------------------------------------------
	# ACTUALIZAR TAMBIÉN EL CACHE DE PRESENCIA
	# -----------------------------------------------------
	#
	# Si GameplayScreen se recrea, remote_players conserva
	# la posición remota más reciente conocida.
	# -----------------------------------------------------

	var remote_player_value: Variant = (
		remote_players[
			state_peer_id
		]
	)


	if typeof(remote_player_value) == TYPE_DICTIONARY:
		var remote_player: Dictionary = (
			remote_player_value
		)


		var world_value: Variant = (
			remote_player.get(
				"world",
				null
			)
		)


		if typeof(world_value) == TYPE_DICTIONARY:
			var world: Dictionary = (
				world_value
			)


			world[
				"position"
			] = authoritative_position


			world[
				"rotation_y"
			] = authoritative_rotation_y


			remote_player[
				"world"
			] = world


			remote_players[
				state_peer_id
			] = remote_player


	remote_player_movement_state_received.emit(
		state_peer_id,
		authoritative_position,
		authoritative_rotation_y,
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
	
	next_move_request_id = 1

	latest_move_request_id = 0

	next_npc_interaction_request_id = 1

	latest_npc_interaction_request_id = 0

	remote_players.clear()

	remote_movement_sequences.clear()

	next_vault_item_move_request_id = 1

	vault_item_move_request_pending = false

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


	var request_id := (
		next_move_request_id
	)


	var message := {
		"version": NETWORK_PROTOCOL_VERSION,

		"type": MESSAGE_MOVE_REQUEST,

		"data": {
			"request_id": request_id,

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


	if result != OK:
		return result


	# -----------------------------------------------------
	# EL REQUEST YA FUE ACEPTADO POR LA CAPA DE TRANSPORTE
	# -----------------------------------------------------

	latest_move_request_id = (
		request_id
	)


	next_move_request_id += 1


	print(
		"GameServerClient | Intención de movimiento enviada",
		" | Request: ",
		request_id,
		" | Destino: ",
		target
	)


	return OK

# =========================================================
# INTERACCIÓN NPC
# =========================================================

func send_npc_interaction_request(
	npc_id: String
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	var normalized_npc_id := (
		npc_id.strip_edges()
	)


	if normalized_npc_id.is_empty():
		return ERR_INVALID_PARAMETER


	if normalized_npc_id.length() > 64:
		return ERR_INVALID_PARAMETER


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer == null:
		return ERR_UNAVAILABLE


	var request_id := (
		next_npc_interaction_request_id
	)


	var message := {
		"version": NETWORK_PROTOCOL_VERSION,

		"type": MESSAGE_NPC_INTERACTION_REQUEST,

		"data": {
			"request_id": request_id,

			"npc_id": normalized_npc_id,
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


	if result != OK:
		return result


	latest_npc_interaction_request_id = (
		request_id
	)


	next_npc_interaction_request_id += 1


	print(
		"GameServerClient | Solicitud de interacción NPC enviada",
		" | Request: ",
		request_id,
		" | NPC: ",
		normalized_npc_id
	)


	return OK

# =========================================================
# DECISIÓN AUTORITATIVA DE MOVIMIENTO
# =========================================================

func _process_movement_decision(
	data: Dictionary
) -> void:
	var decision_peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if (
		decision_peer_id
		!=
		multiplayer.get_unique_id()
	):
		return


	var request_id := int(
		data.get(
			"request_id",
			0
		)
	)


	# -----------------------------------------------------
	# Sólo nos importa la decisión del click más reciente.
	# Una decisión anterior no debe detener una predicción
	# más nueva.
	# -----------------------------------------------------

	if request_id != latest_move_request_id:
		return


	var accepted := bool(
		data.get(
			"accepted",
			false
		)
	)


	var position_value: Variant = (
		data.get(
			"authoritative_position",
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


	var authoritative_position := Vector3(
		float(position_data["x"]),
		float(position_data["y"]),
		float(position_data["z"])
	)


	var authoritative_rotation_y := float(
		data.get(
			"authoritative_rotation_y",
			0.0
		)
	)


	var authorized_target := Vector3.ZERO


	if accepted:
		var target_value: Variant = (
			data.get(
				"authorized_target",
				null
			)
		)


		if typeof(target_value) != TYPE_DICTIONARY:
			return


		var target_data: Dictionary = (
			target_value
		)


		if (
			not target_data.has("x")
			or
			not target_data.has("y")
			or
			not target_data.has("z")
		):
			return


		authorized_target = Vector3(
			float(target_data["x"]),
			float(target_data["y"]),
			float(target_data["z"])
		)


	var reason := String(
		data.get(
			"reason",
			""
		)
	)


	print(
		"GameServerClient | Decisión de movimiento",
		" | Request: ",
		request_id,
		" | Accepted: ",
		accepted,
		" | Target autorizado: ",
		authorized_target
	)


	movement_decision_received.emit(
		request_id,
		accepted,
		authoritative_position,
		authoritative_rotation_y,
		authorized_target,
		reason
	)

# =========================================================
# VALIDAR PRESENCIA REMOTA
# =========================================================

func _parse_remote_player_presence(
	value: Variant
) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}


	var data: Dictionary = (
		value
	)


	var peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if peer_id <= 1:
		return {}


	if peer_id == multiplayer.get_unique_id():
		return {}


	var character_value: Variant = (
		data.get(
			"character",
			null
		)
	)


	if typeof(character_value) != TYPE_DICTIONARY:
		return {}


	var character: Dictionary = (
		character_value
	)


	var character_id := int(
		character.get(
			"id",
			-1
		)
	)


	var character_name := String(
		character.get(
			"name",
			""
		)
	).strip_edges()


	var class_id := String(
		character.get(
			"class_id",
			""
		)
	).strip_edges()


	if (
		character_id <= 0
		or
		character_name.is_empty()
		or
		class_id.is_empty()
	):
		return {}


	var world_value: Variant = (
		data.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return {}


	var world: Dictionary = (
		world_value
	)


	var map_id := String(
		world.get(
			"map_id",
			""
		)
	).strip_edges()


	if map_id.is_empty():
		return {}


	var position_value: Variant = (
		world.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		return {}


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
		return {}


	var position := Vector3(
		float(position_data["x"]),
		float(position_data["y"]),
		float(position_data["z"])
	)


	var rotation_y := float(
		world.get(
			"rotation_y",
			0.0
		)
	)


	return {
		"peer_id": peer_id,

		"character": {
			"id": character_id,
			"name": character_name,
			"class_id": class_id,
			"level": int(
				character.get(
					"level",
					1
				)
			),
		},

		"world": {
			"map_id": map_id,
			"position": position,
			"rotation_y": rotation_y,
		},
	}

# =========================================================
# ROSTER INICIAL DEL MUNDO
# =========================================================

func _process_world_presence_snapshot(
	data: Dictionary
) -> void:
	var players_value: Variant = (
		data.get(
			"players",
			null
		)
	)


	if typeof(players_value) != TYPE_ARRAY:
		return


	var players: Array = (
		players_value
	)


	remote_players.clear()


	for player_value: Variant in players:
		var player := (
			_parse_remote_player_presence(
				player_value
			)
		)


		if player.is_empty():
			continue


		var peer_id := int(
			player.get(
				"peer_id",
				-1
			)
		)


		remote_players[
			peer_id
		] = player


	print(
		"GameServerClient | Roster de mundo recibido",
		" | Remotos: ",
		remote_players.size()
	)


	world_presence_snapshot_received.emit(
		remote_players.values()
	)

# =========================================================
# PLAYER REMOTO ENTRÓ
# =========================================================

func _process_player_presence_joined(
	data: Dictionary
) -> void:
	var player_value: Variant = (
		data.get(
			"player",
			null
		)
	)


	var player := (
		_parse_remote_player_presence(
			player_value
		)
	)


	if player.is_empty():
		return


	var peer_id := int(
		player.get(
			"peer_id",
			-1
		)
	)


	remote_players[
		peer_id
	] = player


	var character: Dictionary = (
		player.get(
			"character",
			{}
		)
	)


	print(
		"GameServerClient | Player remoto entró",
		" | Peer: ",
		peer_id,
		" | Personaje: ",
		character.get(
			"name",
			"?"
		)
	)


	remote_player_joined.emit(
		player.duplicate(
			true
		)
	)

# =========================================================
# PLAYER REMOTO SALIÓ
# =========================================================

func _process_player_presence_left(
	data: Dictionary
) -> void:
	var peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if peer_id <= 1:
		return


	if peer_id == multiplayer.get_unique_id():
		return


	if not remote_players.has(
		peer_id
	):
		return


	remote_players.erase(
		peer_id
	)

	remote_movement_sequences.erase(
		peer_id
	)

	print(
		"GameServerClient | Player remoto salió",
		" | Peer: ",
		peer_id
	)


	remote_player_left.emit(
		peer_id
	)

# =========================================================
# DECISIÓN AUTORITATIVA DE INTERACCIÓN NPC
# =========================================================

func _process_npc_interaction_decision(
	data: Dictionary
) -> void:
	var decision_peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if (
		decision_peer_id
		!=
		multiplayer.get_unique_id()
	):
		return


	var request_id := int(
		data.get(
			"request_id",
			0
		)
	)


	if request_id <= 0:
		return


	# -----------------------------------------------------
	# IGNORAR RESPUESTAS VIEJAS
	# -----------------------------------------------------

	if (
		request_id
		!=
		latest_npc_interaction_request_id
	):
		return


	var accepted := bool(
		data.get(
			"accepted",
			false
		)
	)


	var npc_id := String(
		data.get(
			"npc_id",
			""
		)
	).strip_edges()


	if npc_id.is_empty():
		return


	var service_id := String(
		data.get(
			"service_id",
			""
		)
	).strip_edges()


	var reason := String(
		data.get(
			"reason",
			""
		)
	).strip_edges()


	if (
		accepted
		and
		service_id.is_empty()
	):
		return


	print(
		"GameServerClient | Decisión de interacción NPC",
		" | Request: ",
		request_id,
		" | Accepted: ",
		accepted,
		" | NPC: ",
		npc_id,
		" | Servicio: ",
		service_id,
		" | Motivo: ",
		reason
	)


	npc_interaction_decision_received.emit(
		request_id,
		accepted,
		npc_id,
		service_id,
		reason
	)

# =========================================================
# FINALIZAR SERVICIO NPC
# =========================================================

func send_npc_service_end_request() -> Error:
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

		"type": MESSAGE_NPC_SERVICE_END_REQUEST,

		"data": {},
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


	if result != OK:
		return result


	print(
		"GameServerClient | Solicitud de cierre de servicio NPC enviada."
	)


	return OK

# =========================================================
# SERVICIO NPC FINALIZADO POR SERVIDOR
# =========================================================

func _process_npc_service_ended(
	data: Dictionary
) -> void:
	var npc_id := String(
		data.get(
			"npc_id",
			""
		)
	).strip_edges()


	var service_id := String(
		data.get(
			"service_id",
			""
		)
	).strip_edges()


	var reason := String(
		data.get(
			"reason",
			""
		)
	).strip_edges()


	if npc_id.is_empty():
		return


	if service_id.is_empty():
		return


	if reason.is_empty():
		return


	print(
		"GameServerClient | Servicio NPC finalizado por servidor",
		" | NPC: ",
		npc_id,
		" | Servicio: ",
		service_id,
		" | Motivo: ",
		reason
	)

	vault_item_move_request_pending = false

	npc_service_ended_received.emit(
		npc_id,
		service_id,
		reason
	)

# =========================================================
# SNAPSHOT DE VAULT
# =========================================================

func _process_vault_snapshot(
	snapshot: Dictionary
) -> void:
	var account_id := int(
		snapshot.get(
			"account_id",
			0
		)
	)


	var container := String(
		snapshot.get(
			"container",
			""
		)
	).strip_edges()


	var items_value: Variant = (
		snapshot.get(
			"items",
			null
		)
	)


	if account_id <= 0:
		return


	if container != "vault":
		return


	if typeof(items_value) != TYPE_ARRAY:
		return


	var items: Array = (
		items_value as Array
	)

	vault_item_move_request_pending = false

	print(
		"GameServerClient | Snapshot de Vault recibido",
		" | Cuenta: ",
		account_id,
		" | Items: ",
		items.size()
	)


	vault_snapshot_received.emit(
		snapshot.duplicate(
			true
		)
	)

# =========================================================
# MOVER ITEM DE VAULT
# =========================================================

func send_vault_item_move_request(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	if vault_item_move_request_pending:
		return ERR_BUSY


	var normalized_uid := (
		uid.strip_edges()
	)


	if normalized_uid.is_empty():
		return ERR_INVALID_PARAMETER


	if (
		current_position.x < 0
		or
		current_position.x >= 8
		or
		current_position.y < 0
		or
		current_position.y >= 16
	):
		return ERR_INVALID_PARAMETER


	if (
		new_position.x < 0
		or
		new_position.x >= 8
		or
		new_position.y < 0
		or
		new_position.y >= 16
	):
		return ERR_INVALID_PARAMETER


	if current_position == new_position:
		return ERR_INVALID_PARAMETER


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer == null:
		return ERR_UNAVAILABLE


	var request_id := (
		next_vault_item_move_request_id
	)


	var message := {
		"version": NETWORK_PROTOCOL_VERSION,

		"type": MESSAGE_VAULT_ITEM_MOVE_REQUEST,

		"data": {
			"request_id": request_id,

			"uid": normalized_uid,

			"current_grid_position": {
				"x": current_position.x,
				"y": current_position.y,
			},

			"new_grid_position": {
				"x": new_position.x,
				"y": new_position.y,
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


	if result != OK:
		return result


	vault_item_move_request_pending = true

	next_vault_item_move_request_id += 1


	print(
		"GameServerClient | Solicitud de movimiento Vault enviada",
		" | Request: ",
		request_id,
		" | UID: ",
		normalized_uid,
		" | Desde: ",
		current_position,
		" | Hacia: ",
		new_position
	)


	return OK
