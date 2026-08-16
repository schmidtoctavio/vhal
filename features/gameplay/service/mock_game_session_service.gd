class_name MockGameSessionService
extends GameSessionService


# =========================================================
# ESTADO MOCK
# =========================================================

var active_character_id: int = -1

var active_player_state: PlayerRuntimeState = null

const MOCK_CONNECTION_DELAY_SECONDS: float = 0.75


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

	await (
		Engine
		.get_main_loop()
		as SceneTree
	).create_timer(
		MOCK_CONNECTION_DELAY_SECONDS
	).timeout

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

	if active_player_state.world == null:
		active_character_id = -1

		active_player_state = null


		session_failed.emit(
			"El estado del mundo no es válido."
		)

		return


	var map_definition := (
		MapCatalog.get_definition(
			active_player_state.world.map_id
		)
	)


	if map_definition == null:
		active_character_id = -1

		active_player_state = null


		session_failed.emit(
			"El mapa solicitado no existe."
		)

		return


	if map_definition.scene == null:
		active_character_id = -1

		active_player_state = null


		session_failed.emit(
			"El mapa solicitado no posee una escena válida."
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
