class_name AuthService
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

signal login_succeeded(
	account_id: int,
	account_name: String
)

signal login_failed(
	message: String
)


# =========================================================
# LOGIN
# =========================================================

func login(
	_account: String,
	_password: String
) -> void:
	push_error(
		"AuthService.login() debe ser implementado."
	)
