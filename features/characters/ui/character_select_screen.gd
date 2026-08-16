class_name CharacterSelectScreen
extends Control


# =========================================================
# SEÑALES
# =========================================================

signal create_character_requested(
	slot_index: int
)

signal delete_character_requested(
	character: CharacterSummary
)

signal enter_world_requested(
	character: CharacterSummary
)

signal back_requested


# =========================================================
# CONSTANTES
# =========================================================

const SLOT_COUNT: int = 5


# =========================================================
# REFERENCIAS UI
# =========================================================

@onready var character_name_label: Label = (
	$UILayer/CharacterInfoPanel/ContentMargin/InfoContent/CharacterNameLabel
)

@onready var class_label: Label = (
	$UILayer/CharacterInfoPanel/ContentMargin/InfoContent/ClassLabel
)

@onready var level_label: Label = (
	$UILayer/CharacterInfoPanel/ContentMargin/InfoContent/LevelLabel
)

@onready var slot_label: Label = (
	$UILayer/CharacterInfoPanel/ContentMargin/InfoContent/SlotLabel
)

@onready var create_button: Button = (
	$UILayer/ActionsRow/CreateButton
)

@onready var delete_button: Button = (
	$UILayer/ActionsRow/DeleteButton
)

@onready var enter_world_button: Button = (
	$UILayer/ActionsRow/EnterWorldButton
)

@onready var back_button: Button = (
	$UILayer/BackButton
)


# =========================================================
# DATOS
# =========================================================

var characters: Array[CharacterSummary] = []

var selected_slot_index: int = 0

var delete_confirmation_dialog: ConfirmationDialog = null

var pending_delete_character: CharacterSummary = null

# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_bind_signals()

	_setup_delete_confirmation()


	if characters.size() != SLOT_COUNT:
		characters.resize(
			SLOT_COUNT
		)


	select_slot(
		selected_slot_index
	)

# =========================================================
# CONFIRMACIÓN DE ELIMINACIÓN
# =========================================================

func _setup_delete_confirmation() -> void:
	if delete_confirmation_dialog != null:
		return


	delete_confirmation_dialog = (
		ConfirmationDialog.new()
	)


	delete_confirmation_dialog.name = (
		"DeleteConfirmationDialog"
	)

	delete_confirmation_dialog.title = (
		"Eliminar personaje"
	)

	delete_confirmation_dialog.ok_button_text = (
		"Eliminar"
	)

	delete_confirmation_dialog.cancel_button_text = (
		"Cancelar"
	)

	delete_confirmation_dialog.dialog_autowrap = true


	add_child(
		delete_confirmation_dialog
	)


	if not delete_confirmation_dialog.confirmed.is_connected(
		_on_delete_confirmed
	):
		delete_confirmation_dialog.confirmed.connect(
			_on_delete_confirmed
		)


	if not delete_confirmation_dialog.canceled.is_connected(
		_on_delete_canceled
	):
		delete_confirmation_dialog.canceled.connect(
			_on_delete_canceled
		)

# =========================================================
# CONFIGURACIÓN EXTERNA
# =========================================================

func setup(
	character_list: Array[CharacterSummary],
	initial_slot_index: int = 0
) -> void:
	characters.assign(
		character_list
	)


	if characters.size() != SLOT_COUNT:
		characters.resize(
			SLOT_COUNT
		)


	selected_slot_index = clampi(
		initial_slot_index,
		0,
		SLOT_COUNT - 1
	)


	if is_node_ready():
		select_slot(
			selected_slot_index
		)


# =========================================================
# CONEXIÓN DE SEÑALES
# =========================================================

func _bind_signals() -> void:
	if not create_button.pressed.is_connected(
		_on_create_button_pressed
	):
		create_button.pressed.connect(
			_on_create_button_pressed
		)


	if not delete_button.pressed.is_connected(
		_on_delete_button_pressed
	):
		delete_button.pressed.connect(
			_on_delete_button_pressed
		)


	if not enter_world_button.pressed.is_connected(
		_on_enter_world_button_pressed
	):
		enter_world_button.pressed.connect(
			_on_enter_world_button_pressed
		)


	if not back_button.pressed.is_connected(
		_on_back_button_pressed
	):
		back_button.pressed.connect(
			_on_back_button_pressed
		)


# =========================================================
# SELECCIÓN
# =========================================================

func select_slot(
	slot_index: int
) -> void:
	if slot_index < 0:
		return


	if slot_index >= SLOT_COUNT:
		return


	selected_slot_index = slot_index


	_refresh_selected_character()


func _get_selected_character() -> CharacterSummary:
	if selected_slot_index < 0:
		return null


	if selected_slot_index >= characters.size():
		return null


	return characters[
		selected_slot_index
	]


# =========================================================
# ACTUALIZAR UI
# =========================================================

func _refresh_selected_character() -> void:
	var character: CharacterSummary = (
		_get_selected_character()
	)


	slot_label.text = (
		"Personaje %d / %d"
		% [
			selected_slot_index + 1,
			SLOT_COUNT
		]
	)


	# -----------------------------------------------------
	# SLOT VACÍO
	# -----------------------------------------------------

	if character == null:
		character_name_label.text = (
			"SLOT VACÍO"
		)

		class_label.text = (
			"Clase: -"
		)

		level_label.text = (
			"Nivel: -"
		)


		create_button.disabled = false
		delete_button.disabled = true
		enter_world_button.disabled = true

		return


	# -----------------------------------------------------
	# PERSONAJE EXISTENTE
	# -----------------------------------------------------

	character_name_label.text = (
		character.display_name
	)

	class_label.text = (
		"Clase: %s"
		% character.character_class
	)

	level_label.text = (
		"Nivel: %d"
		% character.level
	)


	create_button.disabled = true
	delete_button.disabled = false
	enter_world_button.disabled = false


# =========================================================
# BOTONES
# =========================================================

func _on_create_button_pressed() -> void:
	if _get_selected_character() != null:
		return


	create_character_requested.emit(
		selected_slot_index
	)


func _on_delete_button_pressed() -> void:
	var character: CharacterSummary = (
		_get_selected_character()
	)


	if character == null:
		return


	if delete_confirmation_dialog == null:
		return


	pending_delete_character = character


	delete_confirmation_dialog.dialog_text = (
		"¿Seguro que querés eliminar a '%s'?\n\n"
		+ "Esta acción eliminará el personaje de forma permanente."
	) % character.display_name


	delete_confirmation_dialog.popup_centered_clamped(
		Vector2i(
			440,
			180
		)
	)

func _on_delete_confirmed() -> void:
	if pending_delete_character == null:
		return


	var character := (
		pending_delete_character
	)


	pending_delete_character = null


	delete_character_requested.emit(
		character
	)


func _on_delete_canceled() -> void:
	pending_delete_character = null

func _on_enter_world_button_pressed() -> void:
	var character: CharacterSummary = (
		_get_selected_character()
	)


	if character == null:
		return


	enter_world_requested.emit(
		character
	)


func _on_back_button_pressed() -> void:
	back_requested.emit()


# =========================================================
# INPUT TEMPORAL DE SELECCIÓN
# =========================================================

func _unhandled_key_input(
	event: InputEvent
) -> void:
	if not event is InputEventKey:
		return


	var key_event := (
		event as InputEventKey
	)


	if not key_event.pressed:
		return


	if key_event.echo:
		return


	# -----------------------------------------------------
	# ANTERIOR
	# -----------------------------------------------------

	if key_event.keycode == KEY_LEFT:
		var previous_index: int = (
			selected_slot_index - 1
		)


		if previous_index < 0:
			previous_index = SLOT_COUNT - 1


		select_slot(
			previous_index
		)


		get_viewport().set_input_as_handled()

		return


	# -----------------------------------------------------
	# SIGUIENTE
	# -----------------------------------------------------

	if key_event.keycode == KEY_RIGHT:
		var next_index: int = (
			selected_slot_index + 1
		)


		if next_index >= SLOT_COUNT:
			next_index = 0


		select_slot(
			next_index
		)


		get_viewport().set_input_as_handled()
