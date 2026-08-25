class_name PlayerInputController
extends Node


signal zoom_in_requested
signal zoom_out_requested

signal move_target_requested(
	target: Vector3
)

signal skill_cast_requested(
	screen_position: Vector2,
	target_entity_id: String
)

signal npc_clicked(
	npc_actor: NpcActor
)

signal basic_attack_requested(
	target_entity_id: String
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
	# CLICK DERECHO
	# → ejecutar la skill seleccionada.
	# -----------------------------------------------------

	if (
		mouse_event.button_index
		==
		MOUSE_BUTTON_RIGHT
	):
		if _is_pointer_over_blocking_ui():
			return


		# -------------------------------------------------
		# CTRL + CLICK DERECHO
		#
		# Queda reservado para PvP.
		#
		# Todavía NO existe el targeting autoritativo de
		# players, por lo tanto no enviamos un cast normal
		# de F16 mientras Ctrl esté presionado.
		# -------------------------------------------------

		if mouse_event.ctrl_pressed:
			get_viewport().set_input_as_handled()


			return


		var skill_target_entity_id := (
			_resolve_mob_target_entity_id(
				mouse_event.position
			)
		)


		skill_cast_requested.emit(
			mouse_event.position,
			skill_target_entity_id
		)


		get_viewport().set_input_as_handled()


		return


	# -----------------------------------------------------
	# CLICK IZQUIERDO
	#
	# terreno → movimiento
	# NPC     → interacción
	# mob     → basic attack
	#
	# CTRL + LEFT CLICK queda reservado para PvP.
	# -----------------------------------------------------

	if (
		mouse_event.button_index
		!=
		MOUSE_BUTTON_LEFT
	):
		return


	if _is_pointer_over_blocking_ui():
		return


	# -----------------------------------------------------
	# CTRL + LEFT CLICK
	#
	# Futuro Basic Attack PvP.
	# Por ahora consumimos el input para evitar que se
	# convierta accidentalmente en movimiento/PvE.
	# -----------------------------------------------------

	if mouse_event.ctrl_pressed:
		get_viewport().set_input_as_handled()


		return


	# -----------------------------------------------------
	# MOB HOSTIL
	# -----------------------------------------------------

	var basic_attack_target_entity_id := (
		_resolve_mob_target_entity_id(
			mouse_event.position
		)
	)


	if not basic_attack_target_entity_id.is_empty():
		basic_attack_requested.emit(
			basic_attack_target_entity_id
		)


		get_viewport().set_input_as_handled()


		return


	# -----------------------------------------------------
	# NPC / TERRENO
	#
	# La función existente ya resuelve primero NPC y,
	# si no existe uno, utiliza el suelo para movimiento.
	# -----------------------------------------------------

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


	var space_state := (
		player_actor
		.get_world_3d()
		.direct_space_state
	)


	# =====================================================
	# EXCLUSIONES
	# =====================================================

	var excluded_rids: Array[RID] = [
		player_actor.get_rid()
	]


	if player_actor.interaction_area != null:
		excluded_rids.append(
			player_actor.interaction_area.get_rid()
		)


	# =====================================================
	# 1. INTERACCIÓN CON NPC
	# =====================================================
	#
	# Primero consultamos ÚNICAMENTE Area3D.
	# El suelo no puede "ganarle" al NPC en esta consulta.
	# =====================================================

	var interaction_query := (
		PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_end
		)
	)


	interaction_query.collide_with_bodies = false
	interaction_query.collide_with_areas = true

	interaction_query.exclude = excluded_rids


	var interaction_result := (
		space_state.intersect_ray(
			interaction_query
		)
	)


	if not interaction_result.is_empty():
		var collider_value: Variant = (
			interaction_result.get(
				"collider",
				null
			)
		)


		var npc_actor := (
			_find_npc_actor_from_collider(
				collider_value
			)
		)


		if npc_actor != null:
			npc_clicked.emit(
				npc_actor
			)


			get_viewport().set_input_as_handled()


			return


	# =====================================================
	# 2. MOVIMIENTO SOBRE EL MUNDO
	# =====================================================

	var movement_query := (
		PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_end
		)
	)


	movement_query.collide_with_bodies = true
	movement_query.collide_with_areas = false

	movement_query.exclude = excluded_rids


	var movement_result := (
		space_state.intersect_ray(
			movement_query
		)
	)


	if movement_result.is_empty():
		return


	var hit_position: Vector3 = (
		movement_result[
			"position"
		]
	)


	move_target_requested.emit(
		hit_position
	)


	# -----------------------------------------------------
	# PREDICCIÓN LOCAL
	# -----------------------------------------------------

	player_actor.set_move_target(
		hit_position
	)


	get_viewport().set_input_as_handled()

# =========================================================
# RESOLVER TARGET DE MOB
# =========================================================

func _resolve_mob_target_entity_id(
	screen_position: Vector2
) -> String:
	if player_actor == null:
		return ""


	if world_camera == null:
		return ""


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


	var space_state := (
		player_actor
		.get_world_3d()
		.direct_space_state
	)


	var excluded_rids: Array[RID] = [
		player_actor.get_rid()
	]


	if player_actor.interaction_area != null:
		excluded_rids.append(
			player_actor.interaction_area.get_rid()
		)


	var query := (
		PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_end
		)
	)


	query.collide_with_bodies = false

	query.collide_with_areas = true

	query.exclude = excluded_rids


	var result := (
		space_state.intersect_ray(
			query
		)
	)


	if result.is_empty():
		return ""


	var collider_value: Variant = (
		result.get(
			"collider",
			null
		)
	)


	var mob_actor := (
		_find_mob_actor_from_collider(
			collider_value
		)
	)


	if mob_actor == null:
		return ""


	if not mob_actor.is_targetable():
		return ""


	var entity_id := (
		mob_actor.get_entity_id()
	)


	if entity_id.is_empty():
		return ""


	print(
		"PlayerInputController | Target PvE detectado",
		" | Entity: ",
		entity_id
	)


	return entity_id

# =========================================================
# RESOLVER NPC DESDE COLLIDER
# =========================================================

func _find_npc_actor_from_collider(
	collider_value: Variant
) -> NpcActor:
	var current_node := (
		collider_value
		as Node
	)


	while current_node != null:
		var npc_actor := (
			current_node
			as NpcActor
		)


		if npc_actor != null:
			return npc_actor


		current_node = (
			current_node.get_parent()
		)


	return null

# =========================================================
# RESOLVER MOB DESDE COLLIDER
# =========================================================

func _find_mob_actor_from_collider(
	collider_value: Variant
) -> MobActor:
	var current_node := (
		collider_value
		as Node
	)


	while current_node != null:
		var mob_actor := (
			current_node
			as MobActor
		)


		if mob_actor != null:
			return mob_actor


		current_node = (
			current_node.get_parent()
		)


	return null
