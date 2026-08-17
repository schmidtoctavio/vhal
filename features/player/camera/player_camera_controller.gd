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
# ZOOM
# =========================================================

@export_group("Zoom")

@export_range(
	5.0,
	30.0,
	0.1
)
var min_distance: float = 16.0

@export_range(
	20.0,
	50.0,
	0.1
)
var max_distance: float = 30.0

@export_range(
	0.5,
	5.0,
	0.1
)
var zoom_step: float = 2.0

@export_range(
	1.0,
	30.0,
	0.1
)
var zoom_sharpness: float = 12.0


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

var current_distance: float = 22.0

var target_distance: float = 22.0


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


	global_position = (
		target.global_position
	)


	var initial_distance := clampf(
		camera_distance,
		min_distance,
		max_distance
	)


	current_distance = initial_distance

	target_distance = initial_distance


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
		_calculate_camera_offset(
			current_distance
		)
	)


	camera.look_at(
		global_position,
		Vector3.UP
	)


# =========================================================
# OFFSET ISOMÉTRICO
# =========================================================

func _calculate_camera_offset(
	distance: float
) -> Vector3:
	var pitch_radians := deg_to_rad(
		pitch_degrees
	)


	var yaw_radians := deg_to_rad(
		yaw_degrees
	)


	var horizontal_distance := (
		distance
		*
		cos(
			pitch_radians
		)
	)


	var vertical_distance := (
		distance
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
# ZOOM
# =========================================================

func zoom_in() -> void:
	target_distance = maxf(
		min_distance,
		target_distance
		-
		zoom_step
	)


func zoom_out() -> void:
	target_distance = minf(
		max_distance,
		target_distance
		+
		zoom_step
	)


func _process_zoom(
	delta: float
) -> void:
	if camera == null:
		return


	if is_equal_approx(
		current_distance,
		target_distance
	):
		current_distance = target_distance

		return


	var zoom_weight := (
		1.0
		-
		exp(
			-zoom_sharpness
			*
			delta
		)
	)


	current_distance = lerpf(
		current_distance,
		target_distance,
		zoom_weight
	)


	if (
		absf(
			current_distance
			-
			target_distance
		)
		<
		0.01
	):
		current_distance = target_distance


	camera.position = (
		_calculate_camera_offset(
			current_distance
		)
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


	_process_zoom(
		delta
	)
