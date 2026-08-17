class_name PlayerInputController
extends Node


# =========================================================
# CONSTANTES
# =========================================================

const RAY_LENGTH: float = 500.0


# =========================================================
# REFERENCIAS
# =========================================================

var player_actor: PlayerActor = null

var world_camera: Camera3D = null


# =========================================================
# ESTADO
# =========================================================

var input_enabled: bool = false


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	actor: PlayerActor,
	camera: Camera3D
) -> bool:
	if actor == null:
		return false


	if camera == null:
		return false


	player_actor = actor

	world_camera = camera

	input_enabled = true


	return true


# =========================================================
# LIMPIAR
# =========================================================

func clear() -> void:
	input_enabled = false

	player_actor = null

	world_camera = null


# =========================================================
# INPUT
# =========================================================

func _unhandled_input(
	event: InputEvent
) -> void:
	if not input_enabled:
		return


	if player_actor == null:
		return


	if world_camera == null:
		return


	var mouse_event := (
		event as InputEventMouseButton
	)


	if mouse_event == null:
		return


	if (
		mouse_event.button_index
		!=
		MOUSE_BUTTON_LEFT
	):
		return


	if not mouse_event.pressed:
		return


	# Reservamos Ctrl + click izquierdo para
	# las futuras acciones de combate.
	if mouse_event.ctrl_pressed:
		return


	_request_move_to_screen_position(
		mouse_event.position
	)


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


	player_actor.set_move_target(
		hit_position
	)


	get_viewport().set_input_as_handled()
