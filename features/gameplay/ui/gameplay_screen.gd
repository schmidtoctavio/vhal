class_name GameplayScreen
extends Control


# =========================================================
# REFERENCIAS
# =========================================================

@onready var gameplay_ui: GameplayUI = (
	$GameplayUI
)


# =========================================================
# ESTADO DEL JUGADOR
# =========================================================

var player_state: PlayerRuntimeState = null


# =========================================================
# ESTADO DE CUENTA
# =========================================================

var account_state: AccountState = null


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	state: PlayerRuntimeState,
	new_account_state: AccountState
) -> void:
	player_state = state

	account_state = new_account_state


	if is_node_ready():
		_apply_states()

		_refresh_character_debug()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_apply_states()

	_refresh_character_debug()


# =========================================================
# APLICAR ESTADOS
# =========================================================

func _apply_states() -> void:
	if player_state != null:
		gameplay_ui.bind_player_state(
			player_state
		)


	gameplay_ui.bind_account_state(
		account_state
	)


# =========================================================
# DEBUG TEMPORAL
# =========================================================

func _refresh_character_debug() -> void:
	if player_state == null:
		return


	if player_state.character_summary == null:
		return


	var character := (
		player_state.character_summary
	)


	print(
		"GAMEPLAY | Personaje: ",
		character.display_name,
		" | Clase: ",
		character.character_class,
		" | Nivel: ",
		character.level
	)
