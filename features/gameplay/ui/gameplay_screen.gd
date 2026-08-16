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
# CONFIGURACIÓN
# =========================================================

func setup(
	state: PlayerRuntimeState
) -> void:
	player_state = state


	if is_node_ready():
		_apply_player_state()

		_refresh_character_debug()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_apply_player_state()

	_refresh_character_debug()


# =========================================================
# APLICAR ESTADO
# =========================================================

func _apply_player_state() -> void:
	if player_state == null:
		return


	gameplay_ui.bind_player_state(
		player_state
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
