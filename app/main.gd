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


# =========================================================
# SERVICIOS
# =========================================================

var auth_service: AuthService = null

var character_service: CharacterService = null

var game_session_service: GameSessionService = (
	MockGameSessionService.new()
)


# =========================================================
# ESTADO TEMPORAL DEL FLUJO
# =========================================================

var pending_create_slot: int = -1

var waiting_for_characters_after_login: bool = false

var pending_game_character: CharacterSummary = null


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


	pending_game_character = character


	_show_loading(
		character
	)


	game_session_service.start_session(
		ClientSession.account_id,
		character.character_id
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
	var return_slot: int = 0


	if pending_game_character != null:
		return_slot = (
			pending_game_character.slot_index
		)


	pending_game_character = null


	print(
		"GameSessionService | Error: ",
		message
	)


	_show_character_select(
		return_slot
	)


func _on_game_session_ended() -> void:
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


	gameplay_screen.setup(
		player_state,
		ClientSession.account_state
	)


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
