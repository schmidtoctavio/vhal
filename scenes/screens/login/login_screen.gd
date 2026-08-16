class_name LoginScreen
extends Control


# =========================================================
# SEÑALES
# =========================================================

signal login_requested(
	account: String,
	password: String
)

signal exit_requested


# =========================================================
# REFERENCIAS
# =========================================================

@onready var username_input: LineEdit = (
	$CenterArea/LoginPanel/ContentMargin/LoginContent/UsernameGroup/UsernameInput
)

@onready var password_input: LineEdit = (
	$CenterArea/LoginPanel/ContentMargin/LoginContent/PasswordGroup/PasswordInput
)

@onready var status_label: Label = (
	$CenterArea/LoginPanel/ContentMargin/LoginContent/StatusLabel
)

@onready var login_button: Button = (
	$CenterArea/LoginPanel/ContentMargin/LoginContent/ButtonsRow/LoginButton
)

@onready var exit_button: Button = (
	$CenterArea/LoginPanel/ContentMargin/LoginContent/ButtonsRow/ExitButton
)


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_bind_signals()

	clear_status()

	username_input.grab_focus()


# =========================================================
# SEÑALES INTERNAS
# =========================================================

func _bind_signals() -> void:
	if not login_button.pressed.is_connected(
		_on_login_button_pressed
	):
		login_button.pressed.connect(
			_on_login_button_pressed
		)


	if not exit_button.pressed.is_connected(
		_on_exit_button_pressed
	):
		exit_button.pressed.connect(
			_on_exit_button_pressed
		)


	if not username_input.text_submitted.is_connected(
		_on_username_submitted
	):
		username_input.text_submitted.connect(
			_on_username_submitted
		)


	if not password_input.text_submitted.is_connected(
		_on_password_submitted
	):
		password_input.text_submitted.connect(
			_on_password_submitted
		)


# =========================================================
# LOGIN
# =========================================================

func _on_login_button_pressed() -> void:
	_request_login()


func _on_username_submitted(
	_text: String
) -> void:
	password_input.grab_focus()


func _on_password_submitted(
	_text: String
) -> void:
	_request_login()


func _request_login() -> void:
	var account := (
		username_input.text.strip_edges()
	)

	var password := (
		password_input.text
	)


	# -----------------------------------------------------
	# VALIDACIÓN LOCAL BÁSICA
	# -----------------------------------------------------

	if account.is_empty():
		show_error(
			"Ingresá tu cuenta."
		)

		username_input.grab_focus()

		return


	if password.is_empty():
		show_error(
			"Ingresá tu contraseña."
		)

		password_input.grab_focus()

		return


	# -----------------------------------------------------
	# SOLICITAR LOGIN
	# -----------------------------------------------------

	clear_status()


	login_requested.emit(
		account,
		password
	)


# =========================================================
# SALIR
# =========================================================

func _on_exit_button_pressed() -> void:
	exit_requested.emit()


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
	username_input.editable = not is_loading
	password_input.editable = not is_loading
	login_button.disabled = is_loading


	if is_loading:
		show_status(
			"Conectando..."
		)
	else:
		clear_status()
