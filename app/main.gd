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

var auth_service: AuthService = (
	MockAuthService.new()
)


# =========================================================
# DATOS TEMPORALES
# =========================================================

var pending_create_slot: int = -1

var next_debug_character_id: int = 100


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	screen_router.setup(
		screen_root
	)


	_bind_services()


	ClientSession.clear_session()


	_show_login()


# =========================================================
# SERVICIOS
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


# =========================================================
# DATOS DEBUG TEMPORALES
# =========================================================

func _setup_debug_account() -> void:
	var debug_characters: Array[CharacterSummary] = []

	debug_characters.resize(
		CHARACTER_SLOT_COUNT
	)


	debug_characters[0] = CharacterSummary.new(
		1,
		"Atilio",
		"Dark Knight",
		120,
		0
	)


	debug_characters[1] = CharacterSummary.new(
		2,
		"Lyra",
		"Elf",
		85,
		1
	)


	debug_characters[2] = CharacterSummary.new(
		3,
		"Merlin",
		"Dark Wizard",
		57,
		2
	)


	ClientSession.set_character_summaries(
		debug_characters
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
	account_name: String
) -> void:
	ClientSession.authenticate(
		account_id,
		account_name
	)


	_setup_debug_account()


	print(
		"Login temporal aceptado | Cuenta: ",
		ClientSession.account_name
	)


	_show_character_select(
		0
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
# ELIMINAR PERSONAJE - TEMPORAL
# =========================================================

func _on_delete_character_requested(
	character: CharacterSummary
) -> void:
	if character == null:
		return


	var slot_index := character.slot_index


	if slot_index < 0:
		return


	if slot_index >= ClientSession.character_summaries.size():
		return


	var updated_characters: Array[CharacterSummary] = []

	updated_characters.assign(
		ClientSession.character_summaries
	)


	updated_characters[
		slot_index
	] = null


	ClientSession.set_character_summaries(
		updated_characters
	)


	if (
		ClientSession.selected_character_id
		==
		character.character_id
	):
		ClientSession.clear_character_selection()


	_show_character_select(
		slot_index
	)


# =========================================================
# ENTRAR AL MUNDO - TODAVÍA TEMPORAL
# =========================================================

func _on_enter_world_requested(
	character: CharacterSummary
) -> void:
	if character == null:
		return


	ClientSession.select_character(
		character
	)


	_show_gameplay(
		character
	)


# =========================================================
# GAMEPLAY
# =========================================================

func _show_gameplay(
	character: CharacterSummary
) -> void:
	if character == null:
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
		character
	)


# =========================================================
# VOLVER AL LOGIN
# =========================================================

func _on_character_select_back_requested() -> void:
	ClientSession.clear_session()

	pending_create_slot = -1


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


	if pending_create_slot >= ClientSession.character_summaries.size():
		return


	if ClientSession.character_summaries[
		pending_create_slot
	] != null:
		return


	var new_character := CharacterSummary.new(
		next_debug_character_id,
		character_name,
		character_class.display_name,
		1,
		pending_create_slot
	)


	next_debug_character_id += 1


	var updated_characters: Array[CharacterSummary] = []

	updated_characters.assign(
		ClientSession.character_summaries
	)


	updated_characters[
		pending_create_slot
	] = new_character


	ClientSession.set_character_summaries(
		updated_characters
	)


	ClientSession.select_character(
		new_character
	)


	var created_slot := pending_create_slot

	pending_create_slot = -1


	_show_character_select(
		created_slot
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
