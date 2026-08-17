class_name PlayerActor
extends CharacterBody3D


# =========================================================
# MOVIMIENTO
# =========================================================

const MOVE_SPEED: float = 4.0

const ROTATION_SPEED: float = 10.0

const MIN_DIRECTION_LENGTH_SQUARED: float = 0.0001


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

@onready var navigation_agent: NavigationAgent3D = (
	$NavigationAgent3D
)


# =========================================================
# ESTADO
# =========================================================

var player_state: PlayerRuntimeState = null


# =========================================================
# ESTADO DE MOVIMIENTO
# =========================================================

var move_target: Vector3 = Vector3.ZERO

var has_move_target: bool = false


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


	if navigation_agent == null:
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


# =========================================================
# PHYSICS
# =========================================================

func _physics_process(
	delta: float
) -> void:
	if player_state == null:
		return


	_apply_gravity(
		delta
	)


	_process_navigation(
		delta
	)


	move_and_slide()


	_sync_world_state()


# =========================================================
# GRAVEDAD
# =========================================================

func _apply_gravity(
	delta: float
) -> void:
	if not is_on_floor():
		velocity += (
			get_gravity()
			*
			delta
		)

		return


	if velocity.y < 0.0:
		velocity.y = 0.0


# =========================================================
# OBJETIVO DE MOVIMIENTO
# =========================================================

func set_move_target(
	target: Vector3
) -> void:
	if navigation_agent == null:
		return


	move_target = target

	has_move_target = true


	navigation_agent.target_position = (
		target
	)


# =========================================================
# PROCESAR NAVEGACIÓN
# =========================================================

func _process_navigation(
	delta: float
) -> void:
	if not has_move_target:
		_stop_horizontal_velocity()


		if character_visual != null:
			character_visual.play_idle()


		return


	if navigation_agent == null:
		stop_movement()

		return


	# -----------------------------------------------------
	# NavigationServer necesita haber sincronizado al menos
	# una vez el mapa antes de consultar una ruta.
	# -----------------------------------------------------

	if (
		NavigationServer3D.map_get_iteration_id(
			navigation_agent.get_navigation_map()
		)
		==
		0
	):
		_stop_horizontal_velocity()

		return


	# -----------------------------------------------------
	# Ruta terminada.
	# -----------------------------------------------------

	if navigation_agent.is_navigation_finished():
		stop_movement()

		return


	# -----------------------------------------------------
	# El agente actualiza internamente su path al consultar
	# get_next_path_position().
	# -----------------------------------------------------

	var next_path_position := (
		navigation_agent.get_next_path_position()
	)


	var direction := (
		next_path_position
		-
		global_position
	)


	# -----------------------------------------------------
	# El movimiento de VHAL todavía ocurre sobre X/Z.
	# La gravedad sigue siendo responsabilidad del actor.
	# -----------------------------------------------------

	direction.y = 0.0


	if (
		direction.length_squared()
		<=
		MIN_DIRECTION_LENGTH_SQUARED
	):
		_stop_horizontal_velocity()

		return


	direction = direction.normalized()


	velocity.x = (
		direction.x
		*
		MOVE_SPEED
	)

	velocity.z = (
		direction.z
		*
		MOVE_SPEED
	)


	_rotate_towards_direction(
		direction,
		delta
	)


	if character_visual != null:
		character_visual.play_run()


# =========================================================
# ROTACIÓN
# =========================================================

func _rotate_towards_direction(
	direction: Vector3,
	delta: float
) -> void:
	var target_rotation := atan2(
		-direction.x,
		-direction.z
	)


	rotation.y = lerp_angle(
		rotation.y,
		target_rotation,
		clampf(
			ROTATION_SPEED
			*
			delta,
			0.0,
			1.0
		)
	)


# =========================================================
# DETENER MOVIMIENTO
# =========================================================

func stop_movement() -> void:
	has_move_target = false


	_stop_horizontal_velocity()


	if character_visual != null:
		character_visual.play_idle()


func _stop_horizontal_velocity() -> void:
	velocity.x = 0.0

	velocity.z = 0.0


# =========================================================
# SINCRONIZAR ESTADO LOCAL
# =========================================================

func _sync_world_state() -> void:
	if player_state == null:
		return


	if player_state.world == null:
		return


	player_state.world.position = (
		global_position
	)


	player_state.world.rotation_y = (
		rotation.y
	)
