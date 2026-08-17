class_name PlayerCameraController
extends Node3D


# =========================================================
# PERFIL DE CÁMARA MU-LIKE
# =========================================================

@export_group("MU-like Camera")

@export_range(
	-180.0,
	180.0,
	0.1
)
var yaw_degrees: float = -45.0

@export_range(
	20.0,
	70.0,
	0.1
)
var pitch_degrees: float = 48.5

@export_range(
	10.0,
	40.0,
	0.1
)
var camera_distance: float = 22.0

@export_range(
	20.0,
	80.0,
	0.1
)
var camera_fov: float = 35.0


# =========================================================
# SEGUIMIENTO
# =========================================================

@export_group("Follow")

@export_range(
	1.0,
	30.0,
	0.1
)
var follow_sharpness: float = 14.0


# =========================================================
# REFERENCIAS
# =========================================================

@onready var camera: Camera3D = (
	$Camera3D
)


# =========================================================
# ESTADO
# =========================================================

var target: Node3D = null

var follow_enabled: bool = false


# =========================================================
# CONFIGURAR
# =========================================================

func setup(
	new_target: Node3D
) -> bool:
	if new_target == null:
		return false


	if camera == null:
		return false


	target = new_target


	# -----------------------------------------------------
	# El controller comienza directamente sobre el target.
	# -----------------------------------------------------

	global_position = (
		target.global_position
	)


	_apply_camera_profile()


	camera.make_current()


	follow_enabled = true


	return true


# =========================================================
# PERFIL DE CÁMARA
# =========================================================

func _apply_camera_profile() -> void:
	if camera == null:
		return


	camera.fov = camera_fov


	camera.position = (
		_calculate_camera_offset()
	)


	# -----------------------------------------------------
	# Calculamos la orientación una sola vez.
	#
	# El ángulo de cámara debe permanecer fijo mientras
	# seguimos al personaje, como en una cámara isométrica.
	# -----------------------------------------------------

	camera.look_at(
		global_position,
		Vector3.UP
	)


# =========================================================
# OFFSET ISOMÉTRICO
# =========================================================

func _calculate_camera_offset() -> Vector3:
	var pitch_radians := deg_to_rad(
		pitch_degrees
	)


	var yaw_radians := deg_to_rad(
		yaw_degrees
	)


	var horizontal_distance := (
		camera_distance
		*
		cos(
			pitch_radians
		)
	)


	var vertical_distance := (
		camera_distance
		*
		sin(
			pitch_radians
		)
	)


	var offset_x := (
		sin(
			yaw_radians
		)
		*
		horizontal_distance
	)


	var offset_z := (
		cos(
			yaw_radians
		)
		*
		horizontal_distance
	)


	return Vector3(
		offset_x,
		vertical_distance,
		offset_z
	)


# =========================================================
# LIMPIAR
# =========================================================

func clear_target() -> void:
	follow_enabled = false

	target = null


# =========================================================
# OBTENER CÁMARA
# =========================================================

func get_camera() -> Camera3D:
	return camera


# =========================================================
# SEGUIMIENTO
# =========================================================

func _process(
	delta: float
) -> void:
	if not follow_enabled:
		return


	if target == null:
		return


	if not is_instance_valid(
		target
	):
		clear_target()

		return


	var follow_weight := (
		1.0
		-
		exp(
			-follow_sharpness
			*
			delta
		)
	)


	global_position = (
		global_position.lerp(
			target.global_position,
			follow_weight
		)
	)
