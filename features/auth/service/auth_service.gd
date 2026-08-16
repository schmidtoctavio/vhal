class_name AuthService
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

@warning_ignore("unused_signal")
signal login_succeeded(
	account_id: int,
	account_name: String,
	access_token: String,
	expires_at: String
)

@warning_ignore("unused_signal")
signal login_failed(
	message: String
)

@warning_ignore("unused_signal")
signal logout_succeeded

@warning_ignore("unused_signal")
signal logout_failed(
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

# =========================================================
# LOGOUT
# =========================================================

func logout(
	_access_token: String
) -> void:
	push_error(
		"AuthService.logout() debe ser implementado."
	)
