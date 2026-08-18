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

const WALK_ANIMATION: StringName = &"ual1/Walk"

const RUN_ANIMATION: StringName = &"ual1/Jog_Fwd"

const ATTACK_ANIMATION: StringName = &"ual1/Sword_Attack"


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

var current_animation: StringName = &""

var remote_character_data: Dictionary = {}

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


	if not play_idle():
		return false


	return true

# =========================================================
# CONFIGURACIÓN DE PLAYER REMOTO
# =========================================================

func setup_remote(
	character_data: Dictionary
) -> bool:
	if character_data.is_empty():
		return false


	var character_id := int(
		character_data.get(
			"id",
			-1
		)
	)


	var character_name := String(
		character_data.get(
			"name",
			""
		)
	).strip_edges()


	var class_id := String(
		character_data.get(
			"class_id",
			""
		)
	).strip_edges()


	if (
		character_id <= 0
		or
		character_name.is_empty()
		or
		class_id.is_empty()
	):
		return false


	player_state = null

	remote_character_data = (
		character_data.duplicate(
			true
		)
	)


	current_animation = &""


	if not _setup_animation_player():
		return false


	if not play_idle():
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


	if not animation_player.animation_finished.is_connected(
		_on_animation_finished
	):
		animation_player.animation_finished.connect(
			_on_animation_finished
		)


	return true


# =========================================================
# IDLE
# =========================================================

func play_idle() -> bool:
	return _play_looping_animation(
		IDLE_ANIMATION
	)


# =========================================================
# WALK
# =========================================================

func play_walk() -> bool:
	return _play_looping_animation(
		WALK_ANIMATION
	)


# =========================================================
# RUN
# =========================================================

func play_run() -> bool:
	return _play_looping_animation(
		RUN_ANIMATION
	)


# =========================================================
# ATTACK
# =========================================================

func play_attack() -> bool:
	if not _has_animation(
		ATTACK_ANIMATION
	):
		return false


	var attack_animation := animation_player.get_animation(
		ATTACK_ANIMATION
	)


	if attack_animation == null:
		return false


	attack_animation.loop_mode = (
		Animation.LOOP_NONE
	)


	current_animation = ATTACK_ANIMATION


	animation_player.play(
		ATTACK_ANIMATION,
		0.1
	)


	return true


# =========================================================
# ANIMACIÓN LOOP
# =========================================================

func _play_looping_animation(
	animation_name: StringName
) -> bool:
	if current_animation == animation_name:
		return true


	if not _has_animation(
		animation_name
	):
		return false


	var animation := animation_player.get_animation(
		animation_name
	)


	if animation == null:
		return false


	animation.loop_mode = (
		Animation.LOOP_LINEAR
	)


	current_animation = animation_name


	animation_player.play(
		animation_name,
		0.15
	)


	return true


# =========================================================
# VALIDAR ANIMACIÓN
# =========================================================

func _has_animation(
	animation_name: StringName
) -> bool:
	if animation_player.has_animation(
		animation_name
	):
		return true


	print(
		"CharacterVisual | No existe la animación: ",
		animation_name
	)


	print(
		"CharacterVisual | Animaciones disponibles: ",
		animation_player.get_animation_list()
	)


	return false


# =========================================================
# ANIMACIÓN FINALIZADA
# =========================================================

func _on_animation_finished(
	animation_name: StringName
) -> void:
	if animation_name != ATTACK_ANIMATION:
		return


	current_animation = &""


	play_idle()
