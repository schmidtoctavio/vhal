class_name GameSessionService
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

@warning_ignore("unused_signal")
signal session_started(
	character_id: int
)

@warning_ignore("unused_signal")
signal session_ended

@warning_ignore("unused_signal")
signal session_failed(
	message: String
)


# =========================================================
# ENTRAR AL MUNDO
# =========================================================

func start_session(
	_account_id: int,
	_character_id: int
) -> void:
	push_error(
		"GameSessionService.start_session() debe ser implementado."
	)


# =========================================================
# SALIR DEL MUNDO
# =========================================================

func end_session() -> void:
	push_error(
		"GameSessionService.end_session() debe ser implementado."
	)
