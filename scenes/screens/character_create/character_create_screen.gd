class_name CharacterCreateScreen
extends Control


# =========================================================
# SEÑALES
# =========================================================

signal create_character_requested(
	name: String,
	character_class: CharacterClassDefinition
)

signal cancel_requested


# =========================================================
# DEFINICIONES TEMPORALES
# =========================================================

const WARRIOR_CLASS: CharacterClassDefinition = preload(
	"res://data/characters/classes/warrior.tres"
)

const MAGE_CLASS: CharacterClassDefinition = preload(
	"res://data/characters/classes/mage.tres"
)

const ARCHER_CLASS: CharacterClassDefinition = preload(
	"res://data/characters/classes/archer.tres"
)


# =========================================================
# REFERENCIAS
# =========================================================

@onready var name_input: LineEdit = (
	$UILayer/CreationPanel/ContentMargin/CreationContent/NameInput
)

@onready var warrior_button: Button = (
	$UILayer/CreationPanel/ContentMargin/CreationContent/ClassList/WarriorButton
)

@onready var mage_button: Button = (
	$UILayer/CreationPanel/ContentMargin/CreationContent/ClassList/MageButton
)

@onready var archer_button: Button = (
	$UILayer/CreationPanel/ContentMargin/CreationContent/ClassList/ArcherButton
)

@onready var class_info: Label = (
	$UILayer/CreationPanel/ContentMargin/CreationContent/ClassInfo
)

@onready var status_label: Label = (
	$UILayer/CreationPanel/ContentMargin/CreationContent/StatusLabel
)

@onready var create_button: Button = (
	$UILayer/ActionsRow/CreateButton
)

@onready var cancel_button: Button = (
	$UILayer/ActionsRow/CancelButton
)


# =========================================================
# ESTADO
# =========================================================

var selected_class: CharacterClassDefinition = null


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_bind_signals()

	clear_status()

	select_class(
		WARRIOR_CLASS
	)

	name_input.grab_focus()


# =========================================================
# SEÑALES
# =========================================================

func _bind_signals() -> void:
	if not warrior_button.pressed.is_connected(
		_on_warrior_button_pressed
	):
		warrior_button.pressed.connect(
			_on_warrior_button_pressed
		)


	if not mage_button.pressed.is_connected(
		_on_mage_button_pressed
	):
		mage_button.pressed.connect(
			_on_mage_button_pressed
		)


	if not archer_button.pressed.is_connected(
		_on_archer_button_pressed
	):
		archer_button.pressed.connect(
			_on_archer_button_pressed
		)


	if not create_button.pressed.is_connected(
		_on_create_button_pressed
	):
		create_button.pressed.connect(
			_on_create_button_pressed
		)


	if not cancel_button.pressed.is_connected(
		_on_cancel_button_pressed
	):
		cancel_button.pressed.connect(
			_on_cancel_button_pressed
		)


	if not name_input.text_submitted.is_connected(
		_on_name_submitted
	):
		name_input.text_submitted.connect(
			_on_name_submitted
		)


# =========================================================
# SELECCIÓN DE CLASE
# =========================================================

func select_class(
	definition: CharacterClassDefinition
) -> void:
	if definition == null:
		return


	selected_class = definition


	class_info.text = (
		"%s\n\n%s"
		% [
			definition.display_name.to_upper(),
			definition.description
		]
	)


	_refresh_class_buttons()


func _refresh_class_buttons() -> void:
	warrior_button.disabled = (
		selected_class == WARRIOR_CLASS
	)

	mage_button.disabled = (
		selected_class == MAGE_CLASS
	)

	archer_button.disabled = (
		selected_class == ARCHER_CLASS
	)


func _on_warrior_button_pressed() -> void:
	select_class(
		WARRIOR_CLASS
	)


func _on_mage_button_pressed() -> void:
	select_class(
		MAGE_CLASS
	)


func _on_archer_button_pressed() -> void:
	select_class(
		ARCHER_CLASS
	)


# =========================================================
# CREAR
# =========================================================

func _on_create_button_pressed() -> void:
	_request_character_creation()


func _on_name_submitted(
	_text: String
) -> void:
	_request_character_creation()


func _request_character_creation() -> void:
	var character_name: String = (
		name_input.text.strip_edges()
	)


	# -----------------------------------------------------
	# VALIDACIÓN LOCAL
	# -----------------------------------------------------

	if character_name.is_empty():
		show_error(
			"Ingresá un nombre para el personaje."
		)

		name_input.grab_focus()

		return


	if character_name.length() < 3:
		show_error(
			"El nombre debe tener al menos 3 caracteres."
		)

		name_input.grab_focus()

		return


	if character_name.length() > 16:
		show_error(
			"El nombre no puede superar los 16 caracteres."
		)

		name_input.grab_focus()

		return


	if selected_class == null:
		show_error(
			"Seleccioná una clase."
		)

		return


	clear_status()


	create_character_requested.emit(
		character_name,
		selected_class
	)


# =========================================================
# CANCELAR
# =========================================================

func _on_cancel_button_pressed() -> void:
	cancel_requested.emit()


# =========================================================
# ESTADO VISUAL
# =========================================================

func clear_status() -> void:
	if not is_node_ready():
		return


	status_label.text = ""


func show_status(
	message: String
) -> void:
	status_label.text = message


func show_error(
	message: String
) -> void:
	status_label.text = message


func set_loading(
	is_loading: bool
) -> void:
	name_input.editable = not is_loading

	warrior_button.disabled = (
		is_loading
		or selected_class == WARRIOR_CLASS
	)

	mage_button.disabled = (
		is_loading
		or selected_class == MAGE_CLASS
	)

	archer_button.disabled = (
		is_loading
		or selected_class == ARCHER_CLASS
	)

	create_button.disabled = is_loading
	cancel_button.disabled = is_loading


	if is_loading:
		show_status(
			"Creando personaje..."
		)
	else:
		clear_status()
