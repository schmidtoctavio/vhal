class_name PlayerActor
extends CharacterBody3D


# =========================================================
# MOVIMIENTO
# =========================================================

const ROTATION_SPEED: float = 10.0

const TARGET_REACHED_DISTANCE: float = 0.3

const MIN_DIRECTION_LENGTH_SQUARED: float = 0.0001

# =========================================================
# RECONCILIACIÓN AUTORITATIVA
# =========================================================

const RECONCILIATION_DEAD_ZONE: float = 0.5

const RECONCILIATION_HARD_SNAP_DISTANCE: float = 2.0

const RECONCILIATION_SOFT_RATIO: float = 0.35

const RECONCILIATION_CORRECTION_SPEED: float = 2.5

const RECONCILIATION_ROTATION_SPEED: float = 8.0

const RECONCILIATION_OFFSET_EPSILON: float = 0.001

const RECONCILIATION_ROTATION_EPSILON: float = 0.01

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

var authorized_movement_speed: float = 0.0

# =========================================================
# ESTADO DE RECONCILIACIÓN
# =========================================================

var last_authoritative_sequence: int = 0

var pending_reconciliation_offset: Vector2 = (
	Vector2.ZERO
)

var pending_authoritative_rotation_y: float = 0.0

var has_pending_authoritative_rotation: bool = false

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
# RECIBIR ESTADO AUTORITATIVO
# =========================================================

func apply_authoritative_movement_state(
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	if sequence <= last_authoritative_sequence:
		return


	last_authoritative_sequence = sequence


	var local_position_2d := Vector2(
		global_position.x,
		global_position.z
	)


	var authoritative_position_2d := Vector2(
		authoritative_position.x,
		authoritative_position.z
	)


	var error_vector := (
		authoritative_position_2d
		-
		local_position_2d
	)


	var error_distance := (
		error_vector.length()
	)


	# -----------------------------------------------------
	# MOVIMIENTO FINALIZADO
	# -----------------------------------------------------
	#
	# moving=false es una afirmación fuerte del servidor:
	# esa es la posición final real.
	# -----------------------------------------------------

	if not moving:
		_apply_authoritative_final_state(
			authoritative_position,
			authoritative_rotation_y,
			sequence,
			error_distance
		)

		return


	# -----------------------------------------------------
	# ERROR GRANDE
	# -----------------------------------------------------

	if (
		error_distance
		>=
		RECONCILIATION_HARD_SNAP_DISTANCE
	):
		_apply_authoritative_hard_correction(
			authoritative_position,
			authoritative_rotation_y,
			sequence,
			error_distance
		)

		return


	# -----------------------------------------------------
	# ERROR MEDIO
	# -----------------------------------------------------
	#
	# No perseguimos continuamente la posición vieja del
	# servidor. Calculamos una corrección FINITA basada en
	# este snapshot y luego la consumimos suavemente.
	# -----------------------------------------------------

	if (
		error_distance
		>
		RECONCILIATION_DEAD_ZONE
	):
		pending_reconciliation_offset = (
			error_vector
			*
			RECONCILIATION_SOFT_RATIO
		)


		print(
			"PlayerActor | Reconciliación suave",
			" | Seq: ",
			sequence,
			" | Error XZ: ",
			error_distance
		)
	else:
		pending_reconciliation_offset = (
			Vector2.ZERO
		)


	pending_authoritative_rotation_y = (
		authoritative_rotation_y
	)


	has_pending_authoritative_rotation = true

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


	_apply_authoritative_reconciliation(
		delta
	)


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


	var navigation_map := (
		navigation_agent.get_navigation_map()
	)


	# -----------------------------------------------------
	# El NavigationServer debe haber sincronizado
	# el mapa antes de resolver destinos.
	# -----------------------------------------------------

	if (
		NavigationServer3D.map_get_iteration_id(
			navigation_map
		)
		==
		0
	):
		return


	# -----------------------------------------------------
	# Resolvemos una ruta desde la posición actual hacia
	# el punto solicitado.
	#
	# El último punto de la ruta siempre queda sobre una
	# superficie navegable y alcanzable desde este actor.
	# -----------------------------------------------------

	var resolved_path := (
		NavigationServer3D.map_get_path(
			navigation_map,
			global_position,
			target,
			true,
			navigation_agent.navigation_layers
		)
	)


	if resolved_path.is_empty():
		stop_movement()

		return


	var resolved_target := (
		resolved_path[
			resolved_path.size()
			-
			1
		]
	)


	move_target = resolved_target

	has_move_target = true


	navigation_agent.target_position = (
		resolved_target
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

	if authorized_movement_speed <= 0.0:
		stop_movement()

		return

	if navigation_agent == null:
		stop_movement()

		return

	if _has_reached_move_target():
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
		if _has_reached_move_target():
			stop_movement()
		else:
			_stop_horizontal_velocity()


		return


	direction = direction.normalized()


	velocity.x = (
		direction.x
		*
		authorized_movement_speed
	)

	velocity.z = (
		direction.z
		*
		authorized_movement_speed
	)


	_rotate_towards_direction(
		direction,
		delta
	)


	if character_visual != null:
		character_visual.play_run()

# =========================================================
# DESTINO ALCANZADO
# =========================================================

func _has_reached_move_target() -> bool:
	var current_position_2d := Vector2(
		global_position.x,
		global_position.z
	)


	var target_position_2d := Vector2(
		move_target.x,
		move_target.z
	)


	return (
		current_position_2d.distance_to(
			target_position_2d
		)
		<=
		TARGET_REACHED_DISTANCE
	)

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

# =========================================================
# CORRECCIÓN AUTORITATIVA FUERTE
# =========================================================

func _apply_authoritative_hard_correction(
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	sequence: int,
	error_distance: float
) -> void:
	var previous_move_target := (
		move_target
	)


	var should_resume_prediction := (
		has_move_target
	)


	global_position = Vector3(
		authoritative_position.x,
		global_position.y,
		authoritative_position.z
	)


	rotation.y = (
		authoritative_rotation_y
	)


	pending_reconciliation_offset = (
		Vector2.ZERO
	)


	has_pending_authoritative_rotation = false


	# -----------------------------------------------------
	# Si todavía estábamos caminando localmente, el
	# NavigationAgent debe continuar desde la nueva
	# posición corregida.
	# -----------------------------------------------------

	if should_resume_prediction:
		set_move_target(
			previous_move_target
		)


	_sync_world_state()


	print(
		"PlayerActor | Corrección autoritativa fuerte",
		" | Seq: ",
		sequence,
		" | Error XZ: ",
		error_distance,
		" | Nueva posición: ",
		global_position
	)

# =========================================================
# POSICIÓN FINAL AUTORITATIVA
# =========================================================

func _apply_authoritative_final_state(
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	sequence: int,
	error_distance: float
) -> void:
	global_position = Vector3(
		authoritative_position.x,
		global_position.y,
		authoritative_position.z
	)


	rotation.y = (
		authoritative_rotation_y
	)


	pending_reconciliation_offset = (
		Vector2.ZERO
	)


	has_pending_authoritative_rotation = false


	stop_movement()


	_sync_world_state()


	print(
		"PlayerActor | Final autoritativo aplicado",
		" | Seq: ",
		sequence,
		" | Error previo XZ: ",
		error_distance,
		" | Posición: ",
		global_position
	)

# =========================================================
# CONSUMIR RECONCILIACIÓN
# =========================================================

func _apply_authoritative_reconciliation(
	delta: float
) -> void:
	if delta <= 0.0:
		return


	# -----------------------------------------------------
	# POSICIÓN
	# -----------------------------------------------------

	var offset_length := (
		pending_reconciliation_offset.length()
	)


	if (
		offset_length
		>
		RECONCILIATION_OFFSET_EPSILON
	):
		var correction_distance := minf(
			RECONCILIATION_CORRECTION_SPEED
			*
			delta,
			offset_length
		)


		var correction := (
			pending_reconciliation_offset.normalized()
			*
			correction_distance
		)


		global_position.x += (
			correction.x
		)


		global_position.z += (
			correction.y
		)


		pending_reconciliation_offset -= (
			correction
		)
	else:
		pending_reconciliation_offset = (
			Vector2.ZERO
		)


	# -----------------------------------------------------
	# ROTACIÓN
	# -----------------------------------------------------

	if not has_pending_authoritative_rotation:
		return


	rotation.y = lerp_angle(
		rotation.y,
		pending_authoritative_rotation_y,
		clampf(
			RECONCILIATION_ROTATION_SPEED
			*
			delta,
			0.0,
			1.0
		)
	)


	var remaining_rotation := absf(
		angle_difference(
			rotation.y,
			pending_authoritative_rotation_y
		)
	)


	if (
		remaining_rotation
		<=
		RECONCILIATION_ROTATION_EPSILON
	):
		rotation.y = (
			pending_authoritative_rotation_y
		)


		has_pending_authoritative_rotation = (
			false
		)

# =========================================================
# DECISIÓN DE MOVIMIENTO DEL SERVIDOR
# =========================================================

func apply_movement_decision(
	request_id: int,
	accepted: bool,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	authorized_target: Vector3,
	movement_speed: float,
	reason: String
) -> void:
	if accepted:
		if movement_speed <= 0.0:
			stop_movement()

			return


		authorized_movement_speed = (
			movement_speed
		)


		set_move_target(
			authorized_target
		)


		print(
			"PlayerActor | Movimiento confirmado",
			" | Request: ",
			request_id,
			" | Target: ",
			authorized_target,
			" | Movement Speed: ",
			authorized_movement_speed
		)


		return


	# -----------------------------------------------------
	# RECHAZADO
	#
	# La predicción no tiene permiso para continuar.
	# -----------------------------------------------------

	authorized_movement_speed = 0.0


	global_position = Vector3(
		authoritative_position.x,
		global_position.y,
		authoritative_position.z
	)


	rotation.y = (
		authoritative_rotation_y
	)


	pending_reconciliation_offset = (
		Vector2.ZERO
	)


	has_pending_authoritative_rotation = false


	stop_movement()


	_sync_world_state()


	print(
		"PlayerActor | Movimiento rechazado por servidor",
		" | Request: ",
		request_id,
		" | Motivo: ",
		reason,
		" | Posición restaurada: ",
		global_position
	)
