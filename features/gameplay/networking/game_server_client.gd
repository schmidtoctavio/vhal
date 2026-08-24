class_name GameServerClient
extends Node


# =========================================================
# SIGNALS PÚBLICAS
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

signal character_inventory_snapshot_received(
	snapshot: Dictionary
)

signal character_equipment_snapshot_received(
	snapshot: Dictionary
)


# =========================================================
# CONFIGURACIÓN DE TRANSPORTE
# =========================================================

const DEFAULT_HOST: String = "127.0.0.1"

const DEFAULT_PORT: int = 7000

const SERVER_PEER_ID: int = 1

const AUTH_TIMEOUT_SECONDS: float = 10.0

const NETWORK_PROTOCOL_VERSION: int = 1


# =========================================================
# ESTADO DE TRANSPORTE
# =========================================================

var network_peer: ENetMultiplayerPeer = null

var connecting: bool = false

var connected: bool = false

var pending_ticket: String = ""

var _failure_emitted: bool = false


# =========================================================
# PROTOCOLOS
# =========================================================

var world_protocol: GameServerWorldProtocol = null

var presence_protocol: GameServerPresenceProtocol = null

var movement_protocol: GameServerMovementProtocol = null

var skill_protocol: GameServerSkillProtocol = null

var npc_protocol: GameServerNpcProtocol = null

var item_protocol: GameServerItemProtocol = null


# =========================================================
# COMPATIBILIDAD DE ESTADO PÚBLICO
# =========================================================

var latest_world_snapshot: Dictionary:
	get:
		if world_protocol == null:
			return {}


		return world_protocol.latest_world_snapshot


var latest_movement_sequence: int:
	get:
		if movement_protocol == null:
			return 0


		return movement_protocol.latest_movement_sequence


var latest_authoritative_position: Vector3:
	get:
		if movement_protocol == null:
			return Vector3.ZERO


		return movement_protocol.latest_authoritative_position


var latest_authoritative_rotation_y: float:
	get:
		if movement_protocol == null:
			return 0.0


		return movement_protocol.latest_authoritative_rotation_y


var latest_authoritative_moving: bool:
	get:
		if movement_protocol == null:
			return false


		return movement_protocol.latest_authoritative_moving


var remote_players: Dictionary:
	get:
		if presence_protocol == null:
			return {}


		return presence_protocol.remote_players


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	if not _setup_protocols():
		push_error(
			"GameServerClient | No se pudieron inicializar los protocolos."
		)


		return


	_connect_multiplayer_signals()


# =========================================================
# SETUP DE PROTOCOLOS
# =========================================================

func _setup_protocols() -> bool:
	world_protocol = GameServerWorldProtocol.new()

	presence_protocol = GameServerPresenceProtocol.new()

	movement_protocol = GameServerMovementProtocol.new()

	skill_protocol = GameServerSkillProtocol.new()

	npc_protocol = GameServerNpcProtocol.new()

	item_protocol = GameServerItemProtocol.new()


	if not world_protocol.setup(
		_get_local_peer_id,
		_fail_connection
	):
		return false


	if not presence_protocol.setup(
		_get_local_peer_id
	):
		return false


	if not movement_protocol.setup(
		_send_protocol_message,
		_get_local_peer_id,
		presence_protocol
	):
		return false

	if not skill_protocol.setup(
		_send_protocol_message
	):
		return false

	if not npc_protocol.setup(
		_send_protocol_message,
		_get_local_peer_id
	):
		return false


	if not item_protocol.setup(
		_send_protocol_message,
		_get_latest_world_snapshot,
		_fail_connection
	):
		return false


	_bind_protocol_signals()


	print(
		"GameServerClient | Protocolos inicializados."
	)


	return true


# =========================================================
# BIND DE PROTOCOLOS
# =========================================================

func _bind_protocol_signals() -> void:
	if not world_protocol.world_snapshot_received.is_connected(
		_on_protocol_world_snapshot_received
	):
		world_protocol.world_snapshot_received.connect(
			_on_protocol_world_snapshot_received
		)


	if not movement_protocol.authoritative_movement_state_received.is_connected(
		_on_protocol_authoritative_movement_state_received
	):
		movement_protocol.authoritative_movement_state_received.connect(
			_on_protocol_authoritative_movement_state_received
		)


	if not movement_protocol.remote_player_movement_state_received.is_connected(
		_on_protocol_remote_player_movement_state_received
	):
		movement_protocol.remote_player_movement_state_received.connect(
			_on_protocol_remote_player_movement_state_received
		)


	if not movement_protocol.movement_decision_received.is_connected(
		_on_protocol_movement_decision_received
	):
		movement_protocol.movement_decision_received.connect(
			_on_protocol_movement_decision_received
		)


	if not presence_protocol.world_presence_snapshot_received.is_connected(
		_on_protocol_world_presence_snapshot_received
	):
		presence_protocol.world_presence_snapshot_received.connect(
			_on_protocol_world_presence_snapshot_received
		)


	if not presence_protocol.remote_player_joined.is_connected(
		_on_protocol_remote_player_joined
	):
		presence_protocol.remote_player_joined.connect(
			_on_protocol_remote_player_joined
		)


	if not presence_protocol.remote_player_left.is_connected(
		_on_protocol_remote_player_left
	):
		presence_protocol.remote_player_left.connect(
			_on_protocol_remote_player_left
		)


	if not npc_protocol.npc_interaction_decision_received.is_connected(
		_on_protocol_npc_interaction_decision_received
	):
		npc_protocol.npc_interaction_decision_received.connect(
			_on_protocol_npc_interaction_decision_received
		)


	if not npc_protocol.npc_service_ended_received.is_connected(
		_on_protocol_npc_service_ended_received
	):
		npc_protocol.npc_service_ended_received.connect(
			_on_protocol_npc_service_ended_received
		)


	if not item_protocol.vault_snapshot_received.is_connected(
		_on_protocol_vault_snapshot_received
	):
		item_protocol.vault_snapshot_received.connect(
			_on_protocol_vault_snapshot_received
		)


	if not item_protocol.character_inventory_snapshot_received.is_connected(
		_on_protocol_character_inventory_snapshot_received
	):
		item_protocol.character_inventory_snapshot_received.connect(
			_on_protocol_character_inventory_snapshot_received
		)


	if not item_protocol.character_equipment_snapshot_received.is_connected(
		_on_protocol_character_equipment_snapshot_received
	):
		item_protocol.character_equipment_snapshot_received.connect(
			_on_protocol_character_equipment_snapshot_received
		)


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


	if not scene_multiplayer.peer_packet.is_connected(
		_on_peer_packet
	):
		scene_multiplayer.peer_packet.connect(
			_on_peer_packet
		)


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


	var data_value: Variant = (
		message.get(
			"data",
			null
		)
	)


	if world_protocol.process_message(
		message_type,
		data_value
	):
		return


	if movement_protocol.process_message(
		message_type,
		data_value
	):
		return


	if presence_protocol.process_message(
		message_type,
		data_value
	):
		return


	if npc_protocol.process_message(
		message_type,
		data_value
	):
		return


	item_protocol.process_message(
		message_type,
		data_value
	)


# =========================================================
# ENVIAR MENSAJE DE PROTOCOLO
# =========================================================

func _send_protocol_message(
	message_type: String,
	data: Dictionary
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	var normalized_type := (
		message_type.strip_edges()
	)


	if normalized_type.is_empty():
		return ERR_INVALID_PARAMETER


	var scene_multiplayer := (
		multiplayer
		as SceneMultiplayer
	)


	if scene_multiplayer == null:
		return ERR_UNAVAILABLE


	var message := {
		"version": NETWORK_PROTOCOL_VERSION,
		"type": normalized_type,
		"data": data,
	}


	var packet := (
		JSON.stringify(
			message
		).to_utf8_buffer()
	)


	return scene_multiplayer.send_bytes(
		packet,
		SERVER_PEER_ID,
		MultiplayerPeer.TRANSFER_MODE_RELIABLE,
		0
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


	if movement_protocol != null:
		movement_protocol.reset()

	if skill_protocol != null:
		skill_protocol.reset()

	if presence_protocol != null:
		presence_protocol.reset()


	if npc_protocol != null:
		npc_protocol.reset()


	if item_protocol != null:
		item_protocol.reset()


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
# API PÚBLICA — MOVEMENT
# =========================================================

func send_move_request(
	target: Vector3
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return movement_protocol.send_move_request(
		target
	)

# =========================================================
# API PÚBLICA — SKILLS
# =========================================================

func send_skill_cast_request(
	skill_id: String,
	target: Dictionary
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	if skill_protocol == null:
		return ERR_UNAVAILABLE


	return skill_protocol.send_skill_cast_request(
		skill_id,
		target
	)

# =========================================================
# API PÚBLICA — NPC
# =========================================================

func send_npc_interaction_request(
	npc_id: String
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return npc_protocol.send_npc_interaction_request(
		npc_id
	)


func send_npc_service_end_request() -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return npc_protocol.send_npc_service_end_request()


# =========================================================
# API PÚBLICA — ITEMS
# =========================================================

func send_vault_item_move_request(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return item_protocol.send_vault_item_move_request(
		uid,
		current_position,
		new_position
	)


func send_inventory_item_move_request(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return item_protocol.send_inventory_item_move_request(
		uid,
		current_position,
		new_position
	)


func send_item_container_transfer_request(
	uid: String,
	source_container: String,
	target_container: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return item_protocol.send_item_container_transfer_request(
		uid,
		source_container,
		target_container,
		current_position,
		new_position
	)


func send_equipment_equip_request(
	uid: String,
	current_position: Vector2i,
	equipment_slot: Variant
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return item_protocol.send_equipment_equip_request(
		uid,
		current_position,
		equipment_slot
	)


func send_equipment_unequip_request(
	uid: String,
	current_equipment_slot: Variant,
	new_position: Vector2i
) -> Error:
	if not connected:
		return ERR_UNAVAILABLE


	return item_protocol.send_equipment_unequip_request(
		uid,
		current_equipment_slot,
		new_position
	)


# =========================================================
# HELPERS PARA PROTOCOLOS
# =========================================================

func _get_local_peer_id() -> int:
	return multiplayer.get_unique_id()


func _get_latest_world_snapshot() -> Dictionary:
	if world_protocol == null:
		return {}


	return world_protocol.get_latest_world_snapshot()


# =========================================================
# FORWARD — WORLD
# =========================================================

func _on_protocol_world_snapshot_received(
	snapshot: Dictionary
) -> void:
	world_snapshot_received.emit(
		snapshot
	)


# =========================================================
# FORWARD — MOVEMENT
# =========================================================

func _on_protocol_authoritative_movement_state_received(
	position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	authoritative_movement_state_received.emit(
		position,
		rotation_y,
		moving,
		sequence
	)


func _on_protocol_remote_player_movement_state_received(
	peer_id: int,
	position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	remote_player_movement_state_received.emit(
		peer_id,
		position,
		rotation_y,
		moving,
		sequence
	)


func _on_protocol_movement_decision_received(
	request_id: int,
	accepted: bool,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	authorized_target: Vector3,
	reason: String
) -> void:
	movement_decision_received.emit(
		request_id,
		accepted,
		authoritative_position,
		authoritative_rotation_y,
		authorized_target,
		reason
	)


# =========================================================
# FORWARD — PRESENCE
# =========================================================

func _on_protocol_world_presence_snapshot_received(
	players: Array
) -> void:
	world_presence_snapshot_received.emit(
		players
	)


func _on_protocol_remote_player_joined(
	player: Dictionary
) -> void:
	remote_player_joined.emit(
		player
	)


func _on_protocol_remote_player_left(
	peer_id: int
) -> void:
	movement_protocol.remove_remote_player(
		peer_id
	)


	remote_player_left.emit(
		peer_id
	)


# =========================================================
# FORWARD — NPC
# =========================================================

func _on_protocol_npc_interaction_decision_received(
	request_id: int,
	accepted: bool,
	npc_id: String,
	service_id: String,
	reason: String
) -> void:
	npc_interaction_decision_received.emit(
		request_id,
		accepted,
		npc_id,
		service_id,
		reason
	)


func _on_protocol_npc_service_ended_received(
	npc_id: String,
	service_id: String,
	reason: String
) -> void:
	item_protocol.cancel_vault_related_mutations()


	npc_service_ended_received.emit(
		npc_id,
		service_id,
		reason
	)


# =========================================================
# FORWARD — ITEMS
# =========================================================

func _on_protocol_vault_snapshot_received(
	snapshot: Dictionary
) -> void:
	vault_snapshot_received.emit(
		snapshot
	)


func _on_protocol_character_inventory_snapshot_received(
	snapshot: Dictionary
) -> void:
	character_inventory_snapshot_received.emit(
		snapshot
	)


func _on_protocol_character_equipment_snapshot_received(
	snapshot: Dictionary
) -> void:
	character_equipment_snapshot_received.emit(
		snapshot
	)
