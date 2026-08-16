class_name MockAuthService
extends AuthService


# =========================================================
# MOCK
# =========================================================

const MOCK_ACCOUNT_ID: int = 1


# =========================================================
# LOGIN
# =========================================================

func login(
	account: String,
	password: String
) -> void:
	var normalized_account := (
		account.strip_edges()
	)


	if normalized_account.is_empty():
		login_failed.emit(
			"Ingresá tu cuenta."
		)

		return


	if password.is_empty():
		login_failed.emit(
			"Ingresá tu contraseña."
		)

		return


	login_succeeded.emit(
		MOCK_ACCOUNT_ID,
		normalized_account
	)
