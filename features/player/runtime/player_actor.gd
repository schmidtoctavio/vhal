class_name PlayerActor
extends CharacterBody3D


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


	if state.world == null:
		return false


	player_state = state


	position = (
		state.world.position
	)


	rotation.y = (
		state.world.rotation_y
	)


	return true
