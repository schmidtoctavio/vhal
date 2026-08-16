class_name MockAuthService
extends AuthService


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


	var login_result := (
		DebugAccountFactory.create_login_result(
			normalized_account
		)
	)


	var account_id := int(
		login_result.get(
			"account_id",
			-1
		)
	)


	var account_name := String(
		login_result.get(
			"account_name",
			""
		)
	)


	if (
		account_id < 0
		or
		account_name.is_empty()
	):
		login_failed.emit(
			"No se pudo crear la cuenta de prueba."
		)

		return


	login_succeeded.emit(
		account_id,
		account_name,
		"",
		""
	)
