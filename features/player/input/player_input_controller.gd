class_name PlayerInputController
extends Node


signal zoom_in_requested
signal zoom_out_requested

signal move_target_requested(
	target: Vector3
)

# =========================================================
# CONSTANTES
# =========================================================

const RAY_LENGTH: float = 500.0


# =========================================================
# REFERENCIAS
# =========================================================

var player_actor: PlayerActor = null

var world_camera: Camera3D = null

var gameplay_ui: Control = null


# =========================================================
# ESTADO
# =========================================================

var input_enabled: bool = false


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	actor: PlayerActor,
	camera: Camera3D,
	ui_root: Control
) -> bool:
	if actor == null:
		return false


	if camera == null:
		return false


	if ui_root == null:
		return false


	player_actor = actor

	world_camera = camera

	gameplay_ui = ui_root

	input_enabled = true


	return true


# =========================================================
# LIMPIAR
# =========================================================

func clear() -> void:
	input_enabled = false

	player_actor = null

	world_camera = null

	gameplay_ui = null


# =========================================================
# INPUT
# =========================================================

func _input(
	event: InputEvent
) -> void:
	if not input_enabled:
		return


	if player_actor == null:
		return


	if world_camera == null:
		return


	if gameplay_ui == null:
		return


	var mouse_event := (
		event as InputEventMouseButton
	)


	if mouse_event == null:
		return


	if not mouse_event.pressed:
		return


	# -----------------------------------------------------
	# RUEDA DEL MOUSE
	# -----------------------------------------------------

	if (
		mouse_event.button_index
		==
		MOUSE_BUTTON_WHEEL_UP
	):
		if _is_pointer_over_blocking_ui():
			return


		zoom_in_requested.emit()


		get_viewport().set_input_as_handled()


		return


	if (
		mouse_event.button_index
		==
		MOUSE_BUTTON_WHEEL_DOWN
	):
		if _is_pointer_over_blocking_ui():
			return


		zoom_out_requested.emit()


		get_viewport().set_input_as_handled()


		return


	# -----------------------------------------------------
	# CLICK IZQUIERDO
	# -----------------------------------------------------

	if (
		mouse_event.button_index
		!=
		MOUSE_BUTTON_LEFT
	):
		return


	# Ctrl + click queda reservado para combate.
	if mouse_event.ctrl_pressed:
		return


	if _is_pointer_over_blocking_ui():
		return


	_request_move_to_screen_position(
		mouse_event.position
	)

# =========================================================
# UI BLOQUEANTE
# =========================================================

func _is_pointer_over_blocking_ui() -> bool:
	var hovered_control := (
		get_viewport().gui_get_hovered_control()
	)


	if hovered_control == null:
		return false


	# -----------------------------------------------------
	# GameplayUI ocupa toda la pantalla.
	#
	# Si el control detectado es exactamente GameplayUI,
	# significa que estamos sobre el mundo vacío.
	# -----------------------------------------------------

	if hovered_control == gameplay_ui:
		return false


	# -----------------------------------------------------
	# GameplayScreen también puede aparecer como root
	# full-screen según el orden de propagación.
	# -----------------------------------------------------

	var gameplay_screen := (
		gameplay_ui.get_parent()
		as Control
	)


	if hovered_control == gameplay_screen:
		return false


	# -----------------------------------------------------
	# Cualquier hijo real de GameplayUI:
	# HUD, botones, slots, ventanas, etc.
	# bloquea el click-to-move.
	# -----------------------------------------------------

	if gameplay_ui.is_ancestor_of(
		hovered_control
	):
		return true


	return false


# =========================================================
# PEDIR MOVIMIENTO
# =========================================================

func _request_move_to_screen_position(
	screen_position: Vector2
) -> void:
	if player_actor == null:
		return


	if world_camera == null:
		return


	var ray_origin := (
		world_camera.project_ray_origin(
			screen_position
		)
	)


	var ray_direction := (
		world_camera.project_ray_normal(
			screen_position
		)
	)


	var ray_end := (
		ray_origin
		+
		ray_direction
		*
		RAY_LENGTH
	)


	var query := (
		PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_end
		)
	)


	query.collide_with_bodies = true

	query.collide_with_areas = false


	query.exclude = [
		player_actor.get_rid()
	]


	var space_state := (
		player_actor
		.get_world_3d()
		.direct_space_state
	)


	var result := (
		space_state.intersect_ray(
			query
		)
	)


	if result.is_empty():
		return


	var hit_position: Vector3 = (
		result["position"]
	)


	move_target_requested.emit(
		hit_position
	)


	# -----------------------------------------------------
	# PREDICCIÓN LOCAL TEMPORAL
	# -----------------------------------------------------
	#
	# El cliente sigue moviendo visualmente al actor
	# durante F13-B2A.
	#
	# El Game Server todavía no posee navegación propia.
	# -----------------------------------------------------

	player_actor.set_move_target(
		hit_position
	)


	# El click ya fue convertido en movimiento.
	# No debe seguir propagándose a la GUI.
	get_viewport().set_input_as_handled()
