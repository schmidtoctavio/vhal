class_name CharacterVisual
extends Node3D


# =========================================================
# ESTADO
# =========================================================

var player_state: PlayerRuntimeState = null


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	state: PlayerRuntimeState
) -> bool:
	if state == null:
		return false


	if state.character_summary == null:
		return false


	player_state = state


	return true
