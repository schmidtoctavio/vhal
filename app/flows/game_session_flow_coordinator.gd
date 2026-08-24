class_name GameSessionFlowCoordinator
extends Node


# =========================================================
# SIGNALS
# =========================================================

signal return_to_character_select_requested(
	initial_slot: int
)


# =========================================================
# PANTALLAS
# =========================================================

const GAMEPLAY_SCREEN_SCENE := preload(
	"res://features/gameplay/ui/gameplay_screen.tscn"
)

const LOADING_SCREEN_SCENE := preload(
	"res://features/gameplay/ui/loading_screen.tscn"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var screen_router: ScreenRouter = null

var game_server_client: GameServerClient = null


# =========================================================
# SERVICIOS
# =========================================================

var game_session_service: GameSessionService = (
	MockGameSessionService.new()
)

var game_session_ticket_service: GameSessionTicketService = null


# =========================================================
# ESTADO DEL FLUJO
# =========================================================

var pending_game_character: CharacterSummary = null

var pending_world_snapshot: Dictionary = {}

var pending_character_inventory_snapshot: Dictionary = {}

var pending_character_equipment_snapshot: Dictionary = {}

var game_session_start_requested: bool = false

var configured: bool = false


# =========================================================
# SETUP
# =========================================================

func setup(
	p_screen_router: ScreenRouter,
	p_game_server_client: GameServerClient
) -> bool:
	if configured:
		return true


	if p_screen_router == null:
		return false


	if p_game_server_client == null:
		return false


	screen_router = p_screen_router

	game_server_client = p_game_server_client


	_setup_services()


	if game_session_ticket_service == null:
		return false


	if game_session_service == null:
		return false


	_bind_services()


	configured = true


	print(
		"GameSessionFlowCoordinator | Inicializado."
	)


	return true


# =========================================================
# CONFIGURAR SERVICIOS
# =========================================================

func _setup_services() -> void:
	var http_game_session_ticket_service := (
		HttpGameSessionTicketService.new()
	)


	http_game_session_ticket_service.setup(
		self
	)


	game_session_ticket_service = (
		http_game_session_ticket_service
	)


# =========================================================
# BIND SERVICES
# =========================================================

func _bind_services() -> void:
	if not game_session_ticket_service.ticket_issued.is_connected(
		_on_game_session_ticket_issued
	):
		game_session_ticket_service.ticket_issued.connect(
			_on_game_session_ticket_issued
		)


	if not game_session_ticket_service.ticket_failed.is_connected(
		_on_game_session_ticket_failed
	):
		game_session_ticket_service.ticket_failed.connect(
			_on_game_session_ticket_failed
		)


	if not game_server_client.game_server_connected.is_connected(
		_on_game_server_connected
	):
		game_server_client.game_server_connected.connect(
			_on_game_server_connected
		)


	if not game_server_client.game_server_connection_failed.is_connected(
		_on_game_server_connection_failed
	):
		game_server_client.game_server_connection_failed.connect(
			_on_game_server_connection_failed
		)


	if not game_server_client.game_server_disconnected.is_connected(
		_on_game_server_disconnected
	):
		game_server_client.game_server_disconnected.connect(
			_on_game_server_disconnected
		)


	if not game_server_client.world_snapshot_received.is_connected(
		_on_world_snapshot_received
	):
		game_server_client.world_snapshot_received.connect(
			_on_world_snapshot_received
		)


	if not game_server_client.authoritative_movement_state_received.is_connected(
		_on_authoritative_movement_state_received
	):
		game_server_client.authoritative_movement_state_received.connect(
			_on_authoritative_movement_state_received
		)


	if not game_server_client.movement_decision_received.is_connected(
		_on_movement_decision_received
	):
		game_server_client.movement_decision_received.connect(
			_on_movement_decision_received
		)


	if not game_server_client.remote_player_joined.is_connected(
		_on_remote_player_joined
	):
		game_server_client.remote_player_joined.connect(
			_on_remote_player_joined
		)


	if not game_server_client.remote_player_left.is_connected(
		_on_remote_player_left
	):
		game_server_client.remote_player_left.connect(
			_on_remote_player_left
		)


	if not game_server_client.remote_player_movement_state_received.is_connected(
		_on_remote_player_movement_state_received
	):
		game_server_client.remote_player_movement_state_received.connect(
			_on_remote_player_movement_state_received
		)


	if not game_server_client.npc_interaction_decision_received.is_connected(
		_on_npc_interaction_decision_received
	):
		game_server_client.npc_interaction_decision_received.connect(
			_on_npc_interaction_decision_received
		)


	if not game_server_client.npc_service_ended_received.is_connected(
		_on_npc_service_ended_received
	):
		game_server_client.npc_service_ended_received.connect(
			_on_npc_service_ended_received
		)


	if not game_server_client.vault_snapshot_received.is_connected(
		_on_vault_snapshot_received
	):
		game_server_client.vault_snapshot_received.connect(
			_on_vault_snapshot_received
		)


	if not game_server_client.character_inventory_snapshot_received.is_connected(
		_on_character_inventory_snapshot_received
	):
		game_server_client.character_inventory_snapshot_received.connect(
			_on_character_inventory_snapshot_received
		)


	if not game_server_client.character_equipment_snapshot_received.is_connected(
		_on_character_equipment_snapshot_received
	):
		game_server_client.character_equipment_snapshot_received.connect(
			_on_character_equipment_snapshot_received
		)


	if not game_session_service.session_started.is_connected(
		_on_game_session_started
	):
		game_session_service.session_started.connect(
			_on_game_session_started
		)


	if not game_session_service.session_ended.is_connected(
		_on_game_session_ended
	):
		game_session_service.session_ended.connect(
			_on_game_session_ended
		)


	if not game_session_service.session_failed.is_connected(
		_on_game_session_failed
	):
		game_session_service.session_failed.connect(
			_on_game_session_failed
		)


# =========================================================
# ENTRAR AL MUNDO
# =========================================================

func enter_world(
	character: CharacterSummary
) -> void:
	if not configured:
		return


	if character == null:
		return


	if not ClientSession.authenticated:
		return


	_reset_pending_snapshots()


	pending_game_character = character


	_show_loading(
		character
	)


	if game_session_ticket_service == null:
		_on_game_session_ticket_failed(
			"El servicio de sesión no está disponible."
		)

		return


	game_session_ticket_service.issue_ticket(
		character.character_id
	)


# =========================================================
# GAME SESSION TICKET
# =========================================================

func _on_game_session_ticket_issued(
	ticket: String,
	character_id: int,
	_expires_at: String
) -> void:
	if pending_game_character == null:
		return


	if (
		pending_game_character.character_id
		!=
		character_id
	):
		_on_game_server_connection_failed(
			"El ticket recibido no corresponde al personaje seleccionado."
		)

		return


	var connection_result := (
		game_server_client.connect_to_game_server(
			ticket
		)
	)


	if connection_result != OK:
		_on_game_server_connection_failed(
			"No se pudo iniciar la conexión al Game Server."
		)


func _on_game_session_ticket_failed(
	message: String
) -> void:
	_on_game_server_connection_failed(
		message
	)


# =========================================================
# GAME SERVER
# =========================================================

func _on_game_server_connected(
	peer_id: int
) -> void:
	print(
		"Game Server conectado | Peer ID: ",
		peer_id
	)


	if pending_game_character == null:
		game_server_client.disconnect_from_game_server()

		return


	print(
		"Game Server conectado | Esperando snapshot autoritativo..."
	)


func _on_world_snapshot_received(
	snapshot: Dictionary
) -> void:
	if pending_game_character == null:
		return


	if not pending_world_snapshot.is_empty():
		return


	var account_id := int(
		snapshot.get(
			"account_id",
			-1
		)
	)


	if account_id != ClientSession.account_id:
		_on_game_server_connection_failed(
			"El snapshot pertenece a otra cuenta."
		)

		return


	var character_value: Variant = (
		snapshot.get(
			"character",
			null
		)
	)


	if typeof(character_value) != TYPE_DICTIONARY:
		_on_game_server_connection_failed(
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


	if (
		character_id
		!=
		pending_game_character.character_id
	):
		_on_game_server_connection_failed(
			"El snapshot pertenece a otro personaje."
		)

		return


	var world_value: Variant = (
		snapshot.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		_on_game_server_connection_failed(
			"El snapshot no posee estado de mundo."
		)

		return


	pending_world_snapshot = (
		snapshot.duplicate(
			true
		)
	)


	print(
		"GameSessionFlowCoordinator | Snapshot autoritativo aceptado",
		" | Character ID: ",
		character_id
	)


	_try_start_game_session_from_authoritative_snapshots()


func _on_game_server_connection_failed(
	message: String
) -> void:
	var return_slot: int = 0


	if pending_game_character != null:
		return_slot = (
			pending_game_character.slot_index
		)


	pending_game_character = null

	_reset_pending_snapshots()


	print(
		"GameServerClient | Error: ",
		message
	)


	game_server_client.disconnect_from_game_server()


	return_to_character_select_requested.emit(
		return_slot
	)


func _on_game_server_disconnected() -> void:
	print(
		"GameServerClient | Se perdió la conexión con el servidor."
	)


	if pending_game_character != null:
		_on_game_server_connection_failed(
			"Se perdió la conexión con el Game Server."
		)

		return


	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen != null:
		game_session_service.end_session()


# =========================================================
# APLICAR WORLD SNAPSHOT
# =========================================================

func _apply_authoritative_world_snapshot(
	player_state: PlayerRuntimeState
) -> bool:
	if player_state == null:
		return false


	if player_state.world == null:
		return false


	if pending_world_snapshot.is_empty():
		return false


	var world_value: Variant = (
		pending_world_snapshot.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return false


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
		return false


	var position_value: Variant = (
		world_data.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		return false


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
		return false


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


	player_state.world.setup(
		map_id,
		position,
		rotation_y
	)


	print(
		"GameSessionFlowCoordinator | Mundo autoritativo aplicado",
		" | Mapa: ",
		map_id,
		" | Posición: ",
		position,
		" | Rotación Y: ",
		rotation_y
	)


	return true


# =========================================================
# MOVIMIENTO AUTORITATIVO → GAMEPLAY
# =========================================================

func _on_authoritative_movement_state_received(
	position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	gameplay_screen.apply_authoritative_movement_state(
		position,
		rotation_y,
		moving,
		sequence
	)


# =========================================================
# RESULTADOS DE SESIÓN
# =========================================================

func _on_game_session_started(
	character_id: int,
	player_state: PlayerRuntimeState
) -> void:
	if pending_game_character == null:
		return


	if player_state == null:
		pending_game_character = null

		game_session_service.end_session()

		return


	if player_state.world == null:
		pending_game_character = null

		game_session_service.end_session()

		return


	if not _apply_authoritative_world_snapshot(
		player_state
	):
		pending_game_character = null

		pending_world_snapshot = {}


		game_session_service.end_session()

		return


	if player_state.world.map_id.strip_edges().is_empty():
		pending_game_character = null


		game_session_service.end_session()

		return


	if (
		pending_game_character.character_id
		!=
		character_id
	):
		pending_game_character = null


		game_session_service.end_session()

		return


	if player_state.character_summary == null:
		player_state.character_summary = (
			pending_game_character
		)


	if (
		player_state.character_summary.character_id
		!=
		character_id
	):
		pending_game_character = null


		game_session_service.end_session()

		return


	if pending_character_inventory_snapshot.is_empty():
		pending_game_character = null

		game_session_start_requested = false

		game_session_service.end_session()

		return


	if not player_state.apply_inventory_snapshot(
		pending_character_inventory_snapshot
	):
		pending_game_character = null

		pending_character_inventory_snapshot = {}

		game_session_start_requested = false

		game_session_service.end_session()

		return


	pending_character_inventory_snapshot = {}

	game_session_start_requested = false


	var character := (
		player_state.character_summary
	)


	pending_game_character = null


	ClientSession.select_character(
		character
	)


	if pending_character_equipment_snapshot.is_empty():
		pending_game_character = null

		pending_world_snapshot = {}

		pending_character_inventory_snapshot = {}

		pending_character_equipment_snapshot = {}

		game_session_start_requested = false


		game_session_service.end_session()

		return


	if not player_state.apply_equipment_snapshot(
		pending_character_equipment_snapshot
	):
		pending_game_character = null

		pending_world_snapshot = {}

		pending_character_inventory_snapshot = {}

		pending_character_equipment_snapshot = {}

		game_session_start_requested = false


		game_session_service.end_session()

		return


	_show_gameplay(
		player_state
	)


func _on_game_session_failed(
	message: String
) -> void:
	game_server_client.disconnect_from_game_server()


	var return_slot: int = 0


	if pending_game_character != null:
		return_slot = (
			pending_game_character.slot_index
		)


	pending_game_character = null

	_reset_pending_snapshots()


	print(
		"GameSessionService | Error: ",
		message
	)


	return_to_character_select_requested.emit(
		return_slot
	)


func _on_game_session_ended() -> void:
	_reset_pending_snapshots()


	game_server_client.disconnect_from_game_server()


	var return_slot := maxi(
		ClientSession.selected_character_slot,
		0
	)


	pending_game_character = null


	ClientSession.clear_character_selection()


	return_to_character_select_requested.emit(
		return_slot
	)


# =========================================================
# LOADING
# =========================================================

func _show_loading(
	character: CharacterSummary
) -> void:
	if character == null:
		return


	var loading_screen := (
		screen_router.change_screen(
			LOADING_SCREEN_SCENE
		)
		as LoadingScreen
	)


	if loading_screen == null:
		return


	loading_screen.setup(
		character.display_name
	)


# =========================================================
# GAMEPLAY
# =========================================================

func _show_gameplay(
	player_state: PlayerRuntimeState
) -> void:
	if player_state == null:
		return


	var gameplay_screen := (
		screen_router.change_screen(
			GAMEPLAY_SCREEN_SCENE
		)
		as GameplayScreen
	)


	if gameplay_screen == null:
		return


	if not gameplay_screen.world_load_failed.is_connected(
		_on_gameplay_load_failed
	):
		gameplay_screen.world_load_failed.connect(
			_on_gameplay_load_failed
		)


	if not gameplay_screen.player_spawn_failed.is_connected(
		_on_gameplay_load_failed
	):
		gameplay_screen.player_spawn_failed.connect(
			_on_gameplay_load_failed
		)


	if not gameplay_screen.movement_intent_requested.is_connected(
		_on_gameplay_movement_intent_requested
	):
		gameplay_screen.movement_intent_requested.connect(
			_on_gameplay_movement_intent_requested
		)

	if not gameplay_screen.skill_cast_intent_requested.is_connected(
		_on_gameplay_skill_cast_intent_requested
	):
		gameplay_screen.skill_cast_intent_requested.connect(
			_on_gameplay_skill_cast_intent_requested
		)

	if not gameplay_screen.npc_interaction_requested.is_connected(
		_on_gameplay_npc_interaction_requested
	):
		gameplay_screen.npc_interaction_requested.connect(
			_on_gameplay_npc_interaction_requested
		)


	if not gameplay_screen.npc_service_end_requested.is_connected(
		_on_gameplay_npc_service_end_requested
	):
		gameplay_screen.npc_service_end_requested.connect(
			_on_gameplay_npc_service_end_requested
		)


	if not gameplay_screen.vault_item_move_requested.is_connected(
		_on_gameplay_vault_item_move_requested
	):
		gameplay_screen.vault_item_move_requested.connect(
			_on_gameplay_vault_item_move_requested
		)


	if not gameplay_screen.inventory_item_move_requested.is_connected(
		_on_gameplay_inventory_item_move_requested
	):
		gameplay_screen.inventory_item_move_requested.connect(
			_on_gameplay_inventory_item_move_requested
		)


	if not gameplay_screen.item_container_transfer_requested.is_connected(
		_on_gameplay_item_container_transfer_requested
	):
		gameplay_screen.item_container_transfer_requested.connect(
			_on_gameplay_item_container_transfer_requested
		)


	if not gameplay_screen.equipment_item_equip_requested.is_connected(
		_on_gameplay_equipment_item_equip_requested
	):
		gameplay_screen.equipment_item_equip_requested.connect(
			_on_gameplay_equipment_item_equip_requested
		)


	if not gameplay_screen.equipment_item_unequip_requested.is_connected(
		_on_gameplay_equipment_item_unequip_requested
	):
		gameplay_screen.equipment_item_unequip_requested.connect(
			_on_gameplay_equipment_item_unequip_requested
		)


	gameplay_screen.setup(
		player_state,
		ClientSession.account_state
	)


	gameplay_screen.sync_remote_players(
		game_server_client.remote_players.values()
	)


# =========================================================
# MOVIMIENTO → GAME SERVER
# =========================================================

func _on_gameplay_movement_intent_requested(
	target: Vector3
) -> void:
	var result := (
		game_server_client.send_move_request(
			target
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo enviar la intención de movimiento.",
		" Error: ",
		result
	)


	game_session_service.end_session()


# =========================================================
# SKILL CAST → GAME SERVER
# =========================================================

func _on_gameplay_skill_cast_intent_requested(
	skill_id: String,
	target: Dictionary
) -> void:
	var result := (
		game_server_client.send_skill_cast_request(
			skill_id,
			target
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo enviar la intención de cast.",
		" Error: ",
		result
	)


	game_session_service.end_session()

# =========================================================
# INTERACCIÓN NPC → GAME SERVER
# =========================================================

func _on_gameplay_npc_interaction_requested(
	npc_id: String,
	_service_id: String
) -> void:
	var result := (
		game_server_client.send_npc_interaction_request(
			npc_id
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo enviar la interacción NPC.",
		" Error: ",
		result
	)


	game_session_service.end_session()


# =========================================================
# ERROR AL PREPARAR GAMEPLAY
# =========================================================

func _on_gameplay_load_failed(
	message: String
) -> void:
	print(
		"GameplayScreen | Error al preparar gameplay: ",
		message
	)


	game_session_service.end_session()


# =========================================================
# DECISIÓN DE MOVIMIENTO
# =========================================================

func _on_movement_decision_received(
	request_id: int,
	accepted: bool,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	authorized_target: Vector3,
	reason: String
) -> void:
	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	gameplay_screen.apply_movement_decision(
		request_id,
		accepted,
		authoritative_position,
		authoritative_rotation_y,
		authorized_target,
		reason
	)


# =========================================================
# PRESENCIA REMOTA → GAMEPLAY
# =========================================================

func _on_remote_player_joined(
	player: Dictionary
) -> void:
	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	gameplay_screen.apply_remote_player_joined(
		player
	)


func _on_remote_player_left(
	peer_id: int
) -> void:
	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	gameplay_screen.apply_remote_player_left(
		peer_id
	)


# =========================================================
# MOVIMIENTO REMOTO → GAMEPLAY
# =========================================================

func _on_remote_player_movement_state_received(
	peer_id: int,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	gameplay_screen.apply_remote_player_movement_state(
		peer_id,
		authoritative_position,
		authoritative_rotation_y,
		moving,
		sequence
	)


# =========================================================
# DECISIÓN AUTORITATIVA NPC
# =========================================================

func _on_npc_interaction_decision_received(
	request_id: int,
	accepted: bool,
	npc_id: String,
	service_id: String,
	reason: String
) -> void:
	print(
		"GameSessionFlowCoordinator | Decisión autoritativa NPC",
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


	if not accepted:
		return


	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	if gameplay_screen.apply_authorized_npc_service(
		npc_id,
		service_id
	):
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo aplicar el servicio NPC autorizado",
		" | NPC: ",
		npc_id,
		" | Servicio: ",
		service_id
	)


# =========================================================
# FINALIZAR SERVICIO NPC → GAME SERVER
# =========================================================

func _on_gameplay_npc_service_end_requested() -> void:
	var result := (
		game_server_client.send_npc_service_end_request()
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo finalizar el servicio NPC.",
		" Error: ",
		result
	)


	game_session_service.end_session()


# =========================================================
# SERVICIO NPC FINALIZADO POR SERVER
# =========================================================

func _on_npc_service_ended_received(
	npc_id: String,
	service_id: String,
	reason: String
) -> void:
	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	gameplay_screen.apply_authoritative_npc_service_end(
		npc_id,
		service_id,
		reason
	)


# =========================================================
# SNAPSHOT AUTORITATIVO DE VAULT
# =========================================================

func _on_vault_snapshot_received(
	snapshot: Dictionary
) -> void:
	var account_id := int(
		snapshot.get(
			"account_id",
			0
		)
	)


	if account_id != ClientSession.account_id:
		print(
			"GameSessionFlowCoordinator | "
			+
			"Snapshot de Vault rechazado: cuenta incorrecta."
		)

		return


	var items_value: Variant = (
		snapshot.get(
			"items",
			null
		)
	)


	if typeof(items_value) != TYPE_ARRAY:
		return


	var items: Array = (
		items_value as Array
	)


	if ClientSession.account_state == null:
		print(
			"GameSessionFlowCoordinator | "
			+
			"No existe AccountState para aplicar Vault."
		)

		return


	if not ClientSession.account_state.apply_vault_snapshot(
		snapshot
	):
		print(
			"GameSessionFlowCoordinator | "
			+
			"Snapshot autoritativo de Vault inválido."
		)

		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"Snapshot autoritativo de Vault confirmado",
		" | Cuenta: ",
		account_id,
		" | Items: ",
		items.size()
	)


	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	if gameplay_screen.apply_authoritative_vault_ready():
		return


	if gameplay_screen.refresh_authoritative_vault():
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"Vault hidratada pero no existe "
		+
		"un servicio Warehouse activo."
	)


# =========================================================
# MOVIMIENTO VAULT → GAME SERVER
# =========================================================

func _on_gameplay_vault_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	var result := (
		game_server_client.send_vault_item_move_request(
			uid,
			current_position,
			new_position
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo enviar movimiento de Vault",
		" | UID: ",
		uid,
		" | Error: ",
		result
	)


# =========================================================
# EQUIPMENT AUTORITATIVO RECIBIDO
# =========================================================

func _on_character_equipment_snapshot_received(
	snapshot: Dictionary
) -> void:
	var account_id := int(
		snapshot.get(
			"account_id",
			0
		)
	)


	var character_id := int(
		snapshot.get(
			"character_id",
			0
		)
	)


	var items_value: Variant = (
		snapshot.get(
			"items",
			null
		)
	)


	if account_id != ClientSession.account_id:
		_on_game_server_connection_failed(
			"El Equipment recibido pertenece a otra cuenta."
		)

		return


	if character_id <= 0:
		_on_game_server_connection_failed(
			"El Equipment recibido no posee un personaje válido."
		)

		return


	if typeof(items_value) != TYPE_ARRAY:
		_on_game_server_connection_failed(
			"El Equipment recibido posee items inválidos."
		)

		return


	if pending_game_character != null:
		if not pending_character_equipment_snapshot.is_empty():
			return


		if (
			character_id
			!=
			pending_game_character.character_id
		):
			_on_game_server_connection_failed(
				(
					"El Equipment recibido no corresponde "
					+
					"al personaje seleccionado."
				)
			)

			return


		pending_character_equipment_snapshot = (
			snapshot.duplicate(
				true
			)
		)


		print(
			"GameSessionFlowCoordinator | "
			+
			"Snapshot autoritativo de Equipment aceptado",
			" | Character ID: ",
			character_id,
			" | Items: ",
			(
				items_value
				as Array
			).size()
		)


		_try_start_game_session_from_authoritative_snapshots()

		return


	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	if not gameplay_screen.apply_authoritative_equipment_snapshot(
		snapshot
	):
		_on_game_server_connection_failed(
			"No se pudo aplicar el Equipment autoritativo."
		)

		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"Snapshot autoritativo de Equipment aplicado en Gameplay",
		" | Character ID: ",
		character_id,
		" | Items: ",
		(
			items_value
			as Array
		).size()
	)


# =========================================================
# INVENTORY AUTORITATIVO RECIBIDO
# =========================================================

func _on_character_inventory_snapshot_received(
	snapshot: Dictionary
) -> void:
	var account_id := int(
		snapshot.get(
			"account_id",
			-1
		)
	)


	if account_id != ClientSession.account_id:
		_on_game_server_connection_failed(
			"El Inventory pertenece a otra cuenta."
		)

		return


	var character_id := int(
		snapshot.get(
			"character_id",
			-1
		)
	)


	if pending_game_character != null:
		if not pending_character_inventory_snapshot.is_empty():
			return


		if (
			character_id
			!=
			pending_game_character.character_id
		):
			_on_game_server_connection_failed(
				"El Inventory pertenece a otro personaje."
			)

			return


		pending_character_inventory_snapshot = (
			snapshot.duplicate(
				true
			)
		)


		print(
			"GameSessionFlowCoordinator | "
			+
			"Snapshot autoritativo de Inventory aceptado",
			" | Character ID: ",
			character_id,
			" | Items: ",
			(
				snapshot.get(
					"items",
					[]
				)
				as Array
			).size()
		)


		_try_start_game_session_from_authoritative_snapshots()

		return


	var gameplay_screen := _get_gameplay_screen()


	if gameplay_screen == null:
		return


	if gameplay_screen.player_state == null:
		return


	if gameplay_screen.player_state.character_summary == null:
		return


	if (
		gameplay_screen.player_state
		.character_summary
		.character_id
		!=
		character_id
	):
		print(
			"GameSessionFlowCoordinator | Snapshot de Inventory rechazado",
			" | Motivo: personaje incorrecto"
		)


		game_session_service.end_session()

		return


	if not gameplay_screen.apply_authoritative_inventory_snapshot(
		snapshot
	):
		print(
			"GameSessionFlowCoordinator | "
			+
			"Snapshot autoritativo de Inventory inválido."
		)


		game_session_service.end_session()

		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"Snapshot autoritativo de Inventory aplicado en Gameplay",
		" | Character ID: ",
		character_id,
		" | Items: ",
		(
			snapshot.get(
				"items",
				[]
			)
			as Array
		).size()
	)


# =========================================================
# PREPARAR SESIÓN
# =========================================================

func _try_start_game_session_from_authoritative_snapshots() -> void:
	if game_session_start_requested:
		return


	if pending_game_character == null:
		return


	if pending_world_snapshot.is_empty():
		return


	if pending_character_inventory_snapshot.is_empty():
		return


	if pending_character_equipment_snapshot.is_empty():
		return


	game_session_start_requested = true


	game_session_service.start_session(
		ClientSession.account_id,
		pending_game_character.character_id
	)


# =========================================================
# MOVIMIENTO INVENTORY → GAME SERVER
# =========================================================

func _on_gameplay_inventory_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	var result := (
		game_server_client.send_inventory_item_move_request(
			uid,
			current_position,
			new_position
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo enviar movimiento de Inventory",
		" | UID: ",
		uid,
		" | Error: ",
		result
	)


# =========================================================
# TRANSFERENCIA INVENTORY / VAULT → GAME SERVER
# =========================================================

func _on_gameplay_item_container_transfer_requested(
	uid: String,
	source_container: String,
	target_container: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	var result := (
		game_server_client.send_item_container_transfer_request(
			uid,
			source_container,
			target_container,
			current_position,
			new_position
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | "
		+
		"No se pudo enviar transferencia Inventory/Vault",
		" | UID: ",
		uid,
		" | Desde: ",
		source_container,
		" ",
		current_position,
		" | Hacia: ",
		target_container,
		" ",
		new_position,
		" | Error: ",
		result
	)


# =========================================================
# INVENTORY -> EQUIPMENT → GAME SERVER
# =========================================================

func _on_gameplay_equipment_item_equip_requested(
	uid: String,
	current_position: Vector2i,
	target_slot_id: StringName
) -> void:
	var result := (
		game_server_client.send_equipment_equip_request(
			uid,
			current_position,
			target_slot_id
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | No se pudo enviar Equip",
		" | UID: ",
		uid,
		" | Desde: ",
		current_position,
		" | Slot: ",
		target_slot_id,
		" | Error: ",
		result
	)


# =========================================================
# EQUIPMENT -> INVENTORY → GAME SERVER
# =========================================================

func _on_gameplay_equipment_item_unequip_requested(
	uid: String,
	source_slot_id: StringName,
	new_position: Vector2i
) -> void:
	var result := (
		game_server_client.send_equipment_unequip_request(
			uid,
			source_slot_id,
			new_position
		)
	)


	if result == OK:
		return


	print(
		"GameSessionFlowCoordinator | No se pudo enviar Unequip",
		" | UID: ",
		uid,
		" | Slot: ",
		source_slot_id,
		" | Hacia: ",
		new_position,
		" | Error: ",
		result
	)


# =========================================================
# HELPERS
# =========================================================

func _get_gameplay_screen() -> GameplayScreen:
	return (
		screen_router.current_screen
		as GameplayScreen
	)


func _reset_pending_snapshots() -> void:
	pending_world_snapshot = {}

	pending_character_inventory_snapshot = {}

	pending_character_equipment_snapshot = {}

	game_session_start_requested = false
