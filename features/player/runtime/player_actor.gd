class_name PlayerActor
extends CharacterBody3D


# =========================================================
# REFERENCIAS
# =========================================================

@onready var character_visual: CharacterVisual = (
	$CharacterVisual
)

@onready var camera_target: Marker3D = (
	$CameraTarget
)

@onready var interaction_area: Area3D = (
	$InteractionArea
)

@onready var nameplate_anchor: Marker3D = (
	$NameplateAnchor
)


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


	if state.character_summary == null:
		return false


	player_state = state


	global_position = (
		state.world.position
	)


	rotation.y = (
		state.world.rotation_y
	)


	if character_visual == null:
		return false


	if not character_visual.setup(
		state
	):
		return false


	return true
