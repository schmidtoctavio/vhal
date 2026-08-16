class_name MockGameSessionService
extends GameSessionService


# =========================================================
# ESTADO MOCK
# =========================================================

var active_character_id: int = -1

var active_player_state: PlayerRuntimeState = null


# =========================================================
# ENTRAR AL MUNDO
# =========================================================

func start_session(
	account_id: int,
	character_id: int
) -> void:
	if account_id < 0:
		session_failed.emit(
			"La cuenta no es válida."
		)

		return


	if character_id < 0:
		session_failed.emit(
			"El personaje no es válido."
		)

		return


	active_character_id = character_id


	active_player_state = (
		DebugPlayerStateFactory.create_default()
	)


	if active_player_state == null:
		active_character_id = -1


		session_failed.emit(
			"No se pudo crear el estado del jugador."
		)

		return


	session_started.emit(
		active_character_id,
		active_player_state
	)


# =========================================================
# SALIR DEL MUNDO
# =========================================================

func end_session() -> void:
	active_character_id = -1

	active_player_state = null


	session_ended.emit()
