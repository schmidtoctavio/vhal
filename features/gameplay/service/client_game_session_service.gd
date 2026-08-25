class_name ClientGameSessionService
extends GameSessionService


var active_character_id: int = -1

var active_player_state: PlayerRuntimeState = null


# =========================================================
# INICIAR
# =========================================================

func start_session(
	account_id: int,
	character_id: int
) -> void:
	if account_id <= 0:
		session_failed.emit(
			"La cuenta no es válida."
		)

		return


	if character_id <= 0:
		session_failed.emit(
			"El personaje no es válido."
		)

		return


	active_character_id = character_id


	active_player_state = (
		PlayerRuntimeState.new()
	)


	if active_player_state == null:
		active_character_id = -1


		session_failed.emit(
			"No se pudo crear el estado runtime del jugador."
		)

		return


	session_started.emit(
		active_character_id,
		active_player_state
	)


# =========================================================
# FINALIZAR
# =========================================================

func end_session() -> void:
	active_character_id = -1

	active_player_state = null


	session_ended.emit()
