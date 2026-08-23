extends Node


# =========================================================
# REFERENCIAS
# =========================================================

@onready var screen_root: Control = (
	$ScreenRoot
)

@onready var screen_router: ScreenRouter = (
	$ScreenRouter
)

@onready var game_server_client: GameServerClient = (
	$GameServerClient
)

@onready var account_flow_coordinator: AccountFlowCoordinator = (
	$AccountFlowCoordinator
)

@onready var game_session_flow_coordinator: GameSessionFlowCoordinator = (
	$GameSessionFlowCoordinator
)


# =========================================================
# START
# =========================================================

func _ready() -> void:
	if screen_root == null:
		push_error(
			"Main | No existe ScreenRoot."
		)

		get_tree().quit(
			1
		)

		return


	if screen_router == null:
		push_error(
			"Main | No existe ScreenRouter."
		)

		get_tree().quit(
			2
		)

		return


	if game_server_client == null:
		push_error(
			"Main | No existe GameServerClient."
		)

		get_tree().quit(
			3
		)

		return


	if account_flow_coordinator == null:
		push_error(
			"Main | No existe AccountFlowCoordinator."
		)

		get_tree().quit(
			4
		)

		return


	if game_session_flow_coordinator == null:
		push_error(
			"Main | No existe GameSessionFlowCoordinator."
		)

		get_tree().quit(
			5
		)

		return


	screen_router.setup(
		screen_root
	)


	if not account_flow_coordinator.setup(
		screen_router
	):
		push_error(
			"Main | No se pudo inicializar AccountFlowCoordinator."
		)

		get_tree().quit(
			4
		)

		return


	if not game_session_flow_coordinator.setup(
		screen_router,
		game_server_client
	):
		push_error(
			"Main | No se pudo inicializar GameSessionFlowCoordinator."
		)

		get_tree().quit(
			5
		)

		return


	_bind_flows()


	ClientSession.clear_session()


	account_flow_coordinator.start()


	print(
		"Main | Application flows inicializados."
	)


# =========================================================
# BIND FLOWS
# =========================================================

func _bind_flows() -> void:
	if not account_flow_coordinator.enter_world_requested.is_connected(
		game_session_flow_coordinator.enter_world
	):
		account_flow_coordinator.enter_world_requested.connect(
			game_session_flow_coordinator.enter_world
		)


	if not account_flow_coordinator.exit_requested.is_connected(
		_on_exit_requested
	):
		account_flow_coordinator.exit_requested.connect(
			_on_exit_requested
		)


	if not game_session_flow_coordinator.return_to_character_select_requested.is_connected(
		account_flow_coordinator.show_character_select
	):
		game_session_flow_coordinator.return_to_character_select_requested.connect(
			account_flow_coordinator.show_character_select
		)


# =========================================================
# EXIT
# =========================================================

func _on_exit_requested() -> void:
	get_tree().quit()
