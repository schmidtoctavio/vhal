class_name CharacterVisual
extends Node3D


# =========================================================
# ANIMACIONES
# =========================================================

const BASE_ANIMATION_LIBRARY: AnimationLibrary = preload(
	"res://assets/characters/humanoids/base/animations/ual1_standard.glb"
)

const ANIMATION_LIBRARY_NAME: StringName = &"ual1"

const IDLE_ANIMATION: StringName = &"ual1/Idle"


# =========================================================
# REFERENCIAS
# =========================================================

@onready var animation_player: AnimationPlayer = (
	$AnimationRoot/AnimationPlayer
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


	if state.character_summary == null:
		return false


	player_state = state


	if not _setup_animation_player():
		return false


	if not _play_idle():
		return false


	return true


# =========================================================
# CONFIGURAR ANIMATION PLAYER
# =========================================================

func _setup_animation_player() -> bool:
	if animation_player == null:
		return false


	animation_player.root_node = NodePath(
		"../../ModelRoot/base_humanoid"
	)


	if not animation_player.has_animation_library(
		ANIMATION_LIBRARY_NAME
	):
		var result := animation_player.add_animation_library(
			ANIMATION_LIBRARY_NAME,
			BASE_ANIMATION_LIBRARY
		)


		if result != OK:
			print(
				"CharacterVisual | No se pudo agregar ",
				"la librería de animaciones."
			)

			return false


	return true


# =========================================================
# IDLE
# =========================================================

func _play_idle() -> bool:
	if not animation_player.has_animation(
		IDLE_ANIMATION
	):
		print(
			"CharacterVisual | No existe la animación: ",
			IDLE_ANIMATION
		)


		print(
			"CharacterVisual | Animaciones disponibles: ",
			animation_player.get_animation_list()
		)


		return false


	var idle_animation := (
		animation_player.get_animation(
			IDLE_ANIMATION
		)
	)


	if idle_animation == null:
		return false


	idle_animation.loop_mode = (
		Animation.LOOP_LINEAR
	)


	animation_player.play(
		IDLE_ANIMATION
	)


	return true
