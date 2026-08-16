class_name DebugAccountFactory
extends RefCounted


# =========================================================
# DATOS DEBUG
# =========================================================

const DEFAULT_ACCOUNT_ID: int = 1


# =========================================================
# CREAR RESULTADO DE LOGIN
# =========================================================

static func create_login_result(
	account_name: String
) -> Dictionary:
	return {
		"account_id": DEFAULT_ACCOUNT_ID,
		"account_name": account_name.strip_edges()
	}
