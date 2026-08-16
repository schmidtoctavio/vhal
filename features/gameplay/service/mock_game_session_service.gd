class_name MockGameSessionService
extends GameSessionService


# =========================================================
# VALORES MOCK TEMPORALES
# =========================================================

const MOCK_MAX_HP: int = 100000
const MOCK_MAX_MP: int = 350


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
		PlayerRuntimeState.new()
	)


	# -----------------------------------------------------
	# VITALES MOCK TEMPORALES
	#
	# En F05 esto se moverá a DebugPlayerStateFactory.
	# -----------------------------------------------------

	active_player_state.vitals.set_max_hp(
		MOCK_MAX_HP
	)

	active_player_state.vitals.set_hp(
		MOCK_MAX_HP
	)

	active_player_state.vitals.set_max_mp(
		MOCK_MAX_MP
	)

	active_player_state.vitals.set_mp(
		MOCK_MAX_MP
	)


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
