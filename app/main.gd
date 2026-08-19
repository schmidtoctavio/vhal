extends Node


# =========================================================
# PANTALLAS
# =========================================================

const LOGIN_SCREEN_SCENE := preload(
	"res://features/auth/ui/login_screen.tscn"
)

const CHARACTER_SELECT_SCREEN_SCENE := preload(
	"res://features/characters/ui/character_select_screen.tscn"
)

const CHARACTER_CREATE_SCREEN_SCENE := preload(
	"res://features/characters/ui/character_create_screen.tscn"
)

const GAMEPLAY_SCREEN_SCENE := preload(
	"res://features/gameplay/ui/gameplay_screen.tscn"
)

const LOADING_SCREEN_SCENE := preload(
	"res://features/gameplay/ui/loading_screen.tscn"
)


# =========================================================
# CONSTANTES
# =========================================================

const CHARACTER_SLOT_COUNT: int = 5


# =========================================================
# REFERENCIAS
# =========================================================

@onready var screen_root: Control = (
	$ScreenRoot
)

@onready var screen_router: ScreenRouter = (
	$ScreenRouter
)

@onready var game_server_client: GameServerClient = (
	$GameServerClient
)

# =========================================================
# SERVICIOS
# =========================================================

var auth_service: AuthService = null

var character_service: CharacterService = null

var game_session_service: GameSessionService = (
	MockGameSessionService.new()
)

var game_session_ticket_service: GameSessionTicketService = null

# =========================================================
# ESTADO TEMPORAL DEL FLUJO
# =========================================================

var pending_create_slot: int = -1

var waiting_for_characters_after_login: bool = false

var pending_game_character: CharacterSummary = null

var pending_world_snapshot: Dictionary = {}


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	screen_router.setup(
		screen_root
	)


	_setup_services()

	_bind_services()


	ClientSession.clear_session()


	_show_login()


# =========================================================
# CONFIGURAR SERVICIOS
# =========================================================

func _setup_services() -> void:
	var http_auth_service := (
		HttpAuthService.new()
	)


	http_auth_service.setup(
		self
	)


	auth_service = http_auth_service


	var http_character_service := (
		HttpCharacterService.new()
	)


	http_character_service.setup(
		self
	)


	character_service = (
		http_character_service
	)

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
# SERVICIOS
# =========================================================

func _bind_services() -> void:
	# -----------------------------------------------------
	# AUTH
	# -----------------------------------------------------

	if not auth_service.login_succeeded.is_connected(
		_on_auth_login_succeeded
	):
		auth_service.login_succeeded.connect(
			_on_auth_login_succeeded
		)


	if not auth_service.login_failed.is_connected(
		_on_auth_login_failed
	):
		auth_service.login_failed.connect(
			_on_auth_login_failed
		)


	if not auth_service.logout_succeeded.is_connected(
		_on_auth_logout_succeeded
	):
		auth_service.logout_succeeded.connect(
			_on_auth_logout_succeeded
		)


	if not auth_service.logout_failed.is_connected(
		_on_auth_logout_failed
	):
		auth_service.logout_failed.connect(
			_on_auth_logout_failed
		)


	# -----------------------------------------------------
	# CHARACTERS
	# -----------------------------------------------------

	if not character_service.characters_loaded.is_connected(
		_on_characters_loaded
	):
		character_service.characters_loaded.connect(
			_on_characters_loaded
		)


	if not character_service.character_created.is_connected(
		_on_character_created
	):
		character_service.character_created.connect(
			_on_character_created
		)


	if not character_service.character_deleted.is_connected(
		_on_character_deleted
	):
		character_service.character_deleted.connect(
			_on_character_deleted
		)


	if not character_service.request_failed.is_connected(
		_on_character_request_failed
	):
		character_service.request_failed.connect(
			_on_character_request_failed
		)

	# -----------------------------------------------------
	# GAME SESSION TICKET
	# -----------------------------------------------------

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

	# -----------------------------------------------------
	# GAME SERVER
	# -----------------------------------------------------

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

	# -----------------------------------------------------
	# GAME SESSION
	# -----------------------------------------------------

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


# =========================================================
# LOGIN
# =========================================================

func _show_login() -> void:
	var login_screen := (
		screen_router.change_screen(
			LOGIN_SCREEN_SCENE
		)
		as LoginScreen
	)


	if login_screen == null:
		return


	login_screen.login_requested.connect(
		_on_login_requested
	)

	login_screen.exit_requested.connect(
		_on_exit_requested
	)


func _on_login_requested(
	account: String,
	password: String
) -> void:
	var login_screen := (
		screen_router.current_screen
		as LoginScreen
	)


	if login_screen != null:
		login_screen.set_loading(
			true
		)


	auth_service.login(
		account,
		password
	)


# =========================================================
# RESULTADO DE AUTENTICACIÓN
# =========================================================

func _on_auth_login_succeeded(
	account_id: int,
	account_name: String,
	access_token: String,
	expires_at: String
) -> void:
	ClientSession.authenticate(
		account_id,
		account_name,
		access_token,
		expires_at
	)


	print(
		"Login API aceptado | Cuenta: ",
		ClientSession.account_name
	)


	waiting_for_characters_after_login = true


	character_service.load_characters(
		ClientSession.account_id
	)


func _on_auth_login_failed(
	message: String
) -> void:
	var login_screen := (
		screen_router.current_screen
		as LoginScreen
	)


	if login_screen == null:
		return


	login_screen.set_loading(
		false
	)


	login_screen.show_error(
		message
	)


func _on_exit_requested() -> void:
	get_tree().quit()


# =========================================================
# RESULTADOS DEL SERVICIO DE PERSONAJES
# =========================================================

func _on_characters_loaded(
	characters: Array[CharacterSummary]
) -> void:
	ClientSession.set_character_summaries(
		characters
	)


	if not waiting_for_characters_after_login:
		return


	waiting_for_characters_after_login = false


	_show_character_select(
		0
	)


func _on_character_created(
	character: CharacterSummary
) -> void:
	if character == null:
		return


	ClientSession.select_character(
		character
	)


	var created_slot := (
		character.slot_index
	)


	pending_create_slot = -1


	_show_character_select(
		created_slot
	)


func _on_character_deleted(
	character_id: int,
	slot_index: int
) -> void:
	if (
		ClientSession.selected_character_id
		==
		character_id
	):
		ClientSession.clear_character_selection()


	_show_character_select(
		slot_index
	)


func _on_character_request_failed(
	message: String
) -> void:
	# -----------------------------------------------------
	# ERROR DURANTE CREACIÓN
	# -----------------------------------------------------

	var create_screen := (
		screen_router.current_screen
		as CharacterCreateScreen
	)


	if create_screen != null:
		create_screen.set_loading(
			false
		)


		create_screen.show_error(
			message
		)


		return


	# -----------------------------------------------------
	# ERROR DURANTE CARGA INICIAL
	# -----------------------------------------------------

	var login_screen := (
		screen_router.current_screen
		as LoginScreen
	)


	if login_screen != null:
		waiting_for_characters_after_login = false


		ClientSession.clear_session()


		login_screen.set_loading(
			false
		)


		login_screen.show_error(
			message
		)


		return


	# -----------------------------------------------------
	# FALLBACK TEMPORAL
	# -----------------------------------------------------

	print(
		"CharacterService | Error: ",
		message
	)


# =========================================================
# CHARACTER SELECT
# =========================================================

func _show_character_select(
	initial_slot: int = 0
) -> void:
	var select_screen := (
		screen_router.change_screen(
			CHARACTER_SELECT_SCREEN_SCENE
		)
		as CharacterSelectScreen
	)


	if select_screen == null:
		return


	var safe_slot := clampi(
		initial_slot,
		0,
		CHARACTER_SLOT_COUNT - 1
	)


	select_screen.setup(
		ClientSession.character_summaries,
		safe_slot
	)


	select_screen.create_character_requested.connect(
		_on_create_character_requested
	)

	select_screen.delete_character_requested.connect(
		_on_delete_character_requested
	)

	select_screen.enter_world_requested.connect(
		_on_enter_world_requested
	)

	select_screen.back_requested.connect(
		_on_character_select_back_requested
	)


# =========================================================
# PEDIR CREACIÓN
# =========================================================

func _on_create_character_requested(
	slot_index: int
) -> void:
	if slot_index < 0:
		return


	if slot_index >= ClientSession.character_summaries.size():
		return


	if ClientSession.character_summaries[
		slot_index
	] != null:
		return


	pending_create_slot = slot_index


	_show_character_create()


# =========================================================
# ELIMINAR PERSONAJE
# =========================================================

func _on_delete_character_requested(
	character: CharacterSummary
) -> void:
	if character == null:
		return


	if not ClientSession.authenticated:
		return


	character_service.delete_character(
		ClientSession.account_id,
		character.character_id
	)


# =========================================================
# PEDIR ENTRADA AL MUNDO
# =========================================================

func _on_enter_world_requested(
	character: CharacterSummary
) -> void:
	if character == null:
		return


	if not ClientSession.authenticated:
		return

	pending_world_snapshot = {}

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
		"Main | Snapshot autoritativo aceptado | Character ID: ",
		character_id
	)


	game_session_service.start_session(
		ClientSession.account_id,
		character_id
	)

func _on_game_server_connection_failed(
	message: String
) -> void:
	var return_slot: int = 0


	if pending_game_character != null:
		return_slot = (
			pending_game_character.slot_index
		)


	pending_game_character = null
	pending_world_snapshot = {}

	print(
		"GameServerClient | Error: ",
		message
	)


	game_server_client.disconnect_from_game_server()


	_show_character_select(
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


	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


	if gameplay_screen != null:
		game_session_service.end_session()

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
		"Main | Mundo autoritativo aplicado",
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
	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


	if gameplay_screen == null:
		return


	gameplay_screen.apply_authoritative_movement_state(
		position,
		rotation_y,
		moving,
		sequence
	)

# =========================================================
# RESULTADOS DE SESIÓN DE JUEGO
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


	# -----------------------------------------------------
	# El Mock todavía no conoce el CharacterSummary
	# completo.
	#
	# Main ya posee el summary previamente obtenido por
	# CharacterService, así que lo adjuntamos al runtime.
	# -----------------------------------------------------

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


	var character := (
		player_state.character_summary
	)


	pending_game_character = null


	ClientSession.select_character(
		character
	)


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
	pending_world_snapshot = {}

	print(
		"GameSessionService | Error: ",
		message
	)


	_show_character_select(
		return_slot
	)


func _on_game_session_ended() -> void:
	pending_world_snapshot = {}
	game_server_client.disconnect_from_game_server()
	var return_slot := maxi(
		ClientSession.selected_character_slot,
		0
	)


	pending_game_character = null


	ClientSession.clear_character_selection()


	_show_character_select(
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
		"Main | No se pudo enviar la intención de movimiento.",
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
		"Main | No se pudo enviar la interacción NPC.",
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
# VOLVER AL LOGIN
# =========================================================

func _on_character_select_back_requested() -> void:
	if not ClientSession.authenticated:
		_finish_logout()

		return


	auth_service.logout(
		ClientSession.access_token
	)


func _on_auth_logout_succeeded() -> void:
	_finish_logout()


func _on_auth_logout_failed(
	message: String
) -> void:
	print(
		"AuthService | Error al cerrar sesión: ",
		message
	)


func _finish_logout() -> void:
	ClientSession.clear_session()


	pending_create_slot = -1

	waiting_for_characters_after_login = false

	pending_game_character = null


	_show_login()


# =========================================================
# CHARACTER CREATE
# =========================================================

func _show_character_create() -> void:
	var create_screen := (
		screen_router.change_screen(
			CHARACTER_CREATE_SCREEN_SCENE
		)
		as CharacterCreateScreen
	)


	if create_screen == null:
		return


	create_screen.create_character_requested.connect(
		_on_character_creation_confirmed
	)

	create_screen.cancel_requested.connect(
		_on_character_creation_cancelled
	)


# =========================================================
# CREACIÓN CONFIRMADA
# =========================================================

func _on_character_creation_confirmed(
	character_name: String,
	character_class: CharacterClassDefinition
) -> void:
	if character_class == null:
		return


	if pending_create_slot < 0:
		return


	if not ClientSession.authenticated:
		return


	var create_screen := (
		screen_router.current_screen
		as CharacterCreateScreen
	)


	if create_screen != null:
		create_screen.set_loading(
			true
		)


	character_service.create_character(
		ClientSession.account_id,
		pending_create_slot,
		character_name,
		character_class
	)


# =========================================================
# CANCELAR CREACIÓN
# =========================================================

func _on_character_creation_cancelled() -> void:
	var return_slot := pending_create_slot


	if return_slot < 0:
		return_slot = maxi(
			ClientSession.selected_character_slot,
			0
		)


	pending_create_slot = -1


	_show_character_select(
		return_slot
	)

func _on_movement_decision_received(
	request_id: int,
	accepted: bool,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	authorized_target: Vector3,
	reason: String
) -> void:
	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


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
	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


	if gameplay_screen == null:
		return


	gameplay_screen.apply_remote_player_joined(
		player
	)


func _on_remote_player_left(
	peer_id: int
) -> void:
	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


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
	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


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
# DECISIÓN AUTORITATIVA DE INTERACCIÓN NPC
# =========================================================

func _on_npc_interaction_decision_received(
	request_id: int,
	accepted: bool,
	npc_id: String,
	service_id: String,
	reason: String
) -> void:
	print(
		"Main | Decisión autoritativa NPC",
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


	# -----------------------------------------------------
	# EL GAME SERVER RECHAZÓ LA INTERACCIÓN
	# -----------------------------------------------------

	if not accepted:
		return


	# -----------------------------------------------------
	# APLICAR SOLAMENTE EN GAMEPLAY ACTIVO
	# -----------------------------------------------------

	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


	if gameplay_screen == null:
		return


	if gameplay_screen.apply_authorized_npc_service(
		npc_id,
		service_id
	):
		return


	print(
		"Main | No se pudo aplicar el servicio NPC autorizado",
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
		"Main | No se pudo finalizar el servicio NPC.",
		" Error: ",
		result
	)


	game_session_service.end_session()

# =========================================================
# SERVICIO NPC FINALIZADO POR GAME SERVER
# =========================================================

func _on_npc_service_ended_received(
	npc_id: String,
	service_id: String,
	reason: String
) -> void:
	var gameplay_screen := (
		screen_router.current_screen
		as GameplayScreen
	)


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
			"Main | Snapshot de Vault rechazado: cuenta incorrecta."
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
			"Main | No existe AccountState para aplicar Vault."
		)


		return


	if not ClientSession.account_state.apply_vault_snapshot(
		snapshot
	):
		print(
			"Main | Snapshot autoritativo de Vault inválido."
		)


		return

	print(
		"Main | Snapshot autoritativo de Vault confirmado",
		" | Cuenta: ",
		account_id,
		" | Items: ",
		items.size()
	)
