class_name GameplayScreen
extends Control


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
		_refresh_character_debug()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh_character_debug()


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
