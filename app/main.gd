extends Node


# =========================================================
# PANTALLAS
# =========================================================

const LOGIN_SCREEN_SCENE := preload(
	"res://scenes/screens/login/login_screen.tscn"
)

const CHARACTER_SELECT_SCREEN_SCENE := preload(
	"res://scenes/screens/character_select/character_select_screen.tscn"
)

const CHARACTER_CREATE_SCREEN_SCENE := preload(
	"res://scenes/screens/character_create/character_create_screen.tscn"
)

const GAMEPLAY_SCREEN_SCENE := preload(
	"res://scenes/screens/gameplay/gameplay_screen.tscn"
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


# =========================================================
# PANTALLA ACTUAL
# =========================================================

var current_screen: Control = null


# =========================================================
# DATOS TEMPORALES DE CUENTA
# =========================================================

var account_characters: Array[CharacterSummary] = []

var selected_character_slot: int = 0

var pending_create_slot: int = -1

var next_debug_character_id: int = 100


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_setup_debug_account()

	_show_login()


# =========================================================
# DATOS DEBUG TEMPORALES
# =========================================================

func _setup_debug_account() -> void:
	account_characters.clear()

	account_characters.resize(
		CHARACTER_SLOT_COUNT
	)


	account_characters[0] = CharacterSummary.new(
		1,
		"Atilio",
		"Dark Knight",
		120,
		0
	)


	account_characters[1] = CharacterSummary.new(
		2,
		"Lyra",
		"Elf",
		85,
		1
	)


	account_characters[2] = CharacterSummary.new(
		3,
		"Merlin",
		"Dark Wizard",
		57,
		2
	)


	# Slots 3 y 4 quedan vacíos.


# =========================================================
# CAMBIO DE PANTALLA
# =========================================================

func _change_screen(
	screen_scene: PackedScene
) -> Control:
	if current_screen != null:
		current_screen.queue_free()


	var new_screen := (
		screen_scene.instantiate()
		as Control
	)


	if new_screen == null:
		push_error(
			"No se pudo instanciar la pantalla."
		)

		return null


	screen_root.add_child(
		new_screen
	)


	new_screen.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


	current_screen = new_screen


	return new_screen


# =========================================================
# LOGIN
# =========================================================

func _show_login() -> void:
	var login_screen := (
		_change_screen(
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
	_password: String
) -> void:
	print(
		"Login temporal aceptado | Cuenta: ",
		account
	)


	_show_character_select(
		selected_character_slot
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
		_change_screen(
			CHARACTER_SELECT_SCREEN_SCENE
		)
		as CharacterSelectScreen
	)


	if select_screen == null:
		return


	selected_character_slot = clampi(
		initial_slot,
		0,
		CHARACTER_SLOT_COUNT - 1
	)


	select_screen.setup(
		account_characters,
		selected_character_slot
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


	if slot_index >= account_characters.size():
		return


	if account_characters[
		slot_index
	] != null:
		return


	selected_character_slot = slot_index

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


	var slot_index: int = (
		character.slot_index
	)


	if slot_index < 0:
		return


	if slot_index >= account_characters.size():
		return


	account_characters[
		slot_index
	] = null


	selected_character_slot = slot_index


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


	selected_character_slot = (
		character.slot_index
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
		_change_screen(
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
	_show_login()


# =========================================================
# CHARACTER CREATE
# =========================================================

func _show_character_create() -> void:
	var create_screen := (
		_change_screen(
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


	if pending_create_slot >= account_characters.size():
		return


	if account_characters[
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


	account_characters[
		pending_create_slot
	] = new_character


	selected_character_slot = (
		pending_create_slot
	)


	pending_create_slot = -1


	_show_character_select(
		selected_character_slot
	)


# =========================================================
# CANCELAR CREACIÓN
# =========================================================

func _on_character_creation_cancelled() -> void:
	var return_slot: int = (
		selected_character_slot
	)


	if pending_create_slot >= 0:
		return_slot = pending_create_slot


	pending_create_slot = -1


	_show_character_select(
		return_slot
	)
