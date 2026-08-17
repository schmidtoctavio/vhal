class_name PlayerCameraController
extends Node3D


# =========================================================
# CONFIGURACIÓN
# =========================================================

const CAMERA_OFFSET: Vector3 = Vector3(
	0.0,
	10.0,
	14.0
)

const FOLLOW_SPEED: float = 8.0


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
	# Empezamos inmediatamente sobre el jugador para que
	# la cámara no viaje desde el origen del mundo.
	# -----------------------------------------------------

	global_position = (
		target.global_position
	)


	camera.position = (
		CAMERA_OFFSET
	)


	camera.make_current()


	follow_enabled = true


	_update_camera_look()


	return true


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


	var follow_weight := clampf(
		FOLLOW_SPEED
		*
		delta,
		0.0,
		1.0
	)


	global_position = (
		global_position.lerp(
			target.global_position,
			follow_weight
		)
	)


	_update_camera_look()


# =========================================================
# MIRAR AL PLAYER
# =========================================================

func _update_camera_look() -> void:
	if camera == null:
		return


	if target == null:
		return


	var look_target := (
		target.global_position
	)


	if camera.global_position.is_equal_approx(
		look_target
	):
		return


	camera.look_at(
		look_target,
		Vector3.UP
	)
