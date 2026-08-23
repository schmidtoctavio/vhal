class_name AccountFlowCoordinator
extends Node


# =========================================================
# SIGNALS
# =========================================================

signal enter_world_requested(
	character: CharacterSummary
)

signal exit_requested


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


# =========================================================
# CONSTANTES
# =========================================================

const CHARACTER_SLOT_COUNT: int = 5


# =========================================================
# DEPENDENCIAS
# =========================================================

var screen_router: ScreenRouter = null


# =========================================================
# SERVICIOS
# =========================================================

var auth_service: AuthService = null

var character_service: CharacterService = null


# =========================================================
# ESTADO
# =========================================================

var pending_create_slot: int = -1

var waiting_for_characters_after_login: bool = false

var configured: bool = false


# =========================================================
# SETUP
# =========================================================

func setup(
	p_screen_router: ScreenRouter
) -> bool:
	if configured:
		return true


	if p_screen_router == null:
		return false


	screen_router = p_screen_router


	_setup_services()


	if auth_service == null:
		return false


	if character_service == null:
		return false


	_bind_services()


	configured = true


	print(
		"AccountFlowCoordinator | Inicializado."
	)


	return true


# =========================================================
# START
# =========================================================

func start() -> void:
	if not configured:
		return


	show_login()


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
# BIND SERVICES
# =========================================================

func _bind_services() -> void:
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


# =========================================================
# LOGIN
# =========================================================

func show_login() -> void:
	if not configured:
		return


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
	exit_requested.emit()


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


	show_character_select(
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


	show_character_select(
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


	show_character_select(
		slot_index
	)


func _on_character_request_failed(
	message: String
) -> void:
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


	print(
		"CharacterService | Error: ",
		message
	)


# =========================================================
# CHARACTER SELECT
# =========================================================

func show_character_select(
	initial_slot: int = 0
) -> void:
	if not configured:
		return


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
# ENTRAR AL MUNDO
# =========================================================

func _on_enter_world_requested(
	character: CharacterSummary
) -> void:
	if character == null:
		return


	if not ClientSession.authenticated:
		return


	enter_world_requested.emit(
		character
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


	show_login()


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


	show_character_select(
		return_slot
	)
