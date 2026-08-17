class_name PlayerActor
extends CharacterBody3D


# =========================================================
# MOVIMIENTO
# =========================================================

const MOVE_SPEED: float = 4.0

const TARGET_REACHED_DISTANCE: float = 0.2

const ROTATION_SPEED: float = 10.0


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


	_process_movement(
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
	move_target = target

	has_move_target = true


# =========================================================
# PROCESAR MOVIMIENTO
# =========================================================

func _process_movement(
	delta: float
) -> void:
	if not has_move_target:
		_stop_horizontal_velocity()


		if character_visual != null:
			character_visual.play_idle()


		return


	var offset := (
		move_target
		-
		global_position
	)


	offset.y = 0.0


	if (
		offset.length()
		<=
		TARGET_REACHED_DISTANCE
	):
		stop_movement()

		return


	var direction := (
		offset.normalized()
	)


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
