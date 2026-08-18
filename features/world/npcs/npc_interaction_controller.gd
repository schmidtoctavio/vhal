class_name NpcInteractionController
extends Node


# =========================================================
# SEÑALES
# =========================================================

signal interaction_requested(
	npc_id: String,
	service_id: String
)

signal interaction_rejected(
	npc_id: String,
	reason: String
)


# =========================================================
# ESTADO
# =========================================================

var player_actor: PlayerActor = null


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	actor: PlayerActor
) -> bool:
	if actor == null:
		return false


	player_actor = actor


	return true


# =========================================================
# LIMPIAR
# =========================================================

func clear() -> void:
	player_actor = null


# =========================================================
# SOLICITAR INTERACCIÓN
# =========================================================

func request_interaction(
	npc_actor: NpcActor
) -> bool:
	if player_actor == null:
		return false


	if npc_actor == null:
		return false


	if not is_instance_valid(
		npc_actor
	):
		return false


	if not npc_actor.initialized:
		return false


	var npc_id := (
		npc_actor.get_npc_id()
	)


	var service_id := (
		npc_actor.get_service_id()
	)


	if npc_id.is_empty():
		return false


	if service_id.is_empty():
		return false


	var interaction_range := (
		npc_actor.get_interaction_range()
	)


	if interaction_range <= 0.0:
		return false


	# -----------------------------------------------------
	# DISTANCIA HORIZONTAL X/Z
	# -----------------------------------------------------

	var player_position := Vector2(
		player_actor.global_position.x,
		player_actor.global_position.z
	)


	var npc_position := Vector2(
		npc_actor.global_position.x,
		npc_actor.global_position.z
	)


	var distance := (
		player_position.distance_to(
			npc_position
		)
	)


	if distance > interaction_range:
		print(
			"NpcInteractionController | Fuera de rango",
			" | NPC: ",
			npc_id,
			" | Distancia: ",
			distance,
			" | Máxima: ",
			interaction_range
		)


		interaction_rejected.emit(
			npc_id,
			"out_of_range"
		)


		return false


	print(
		"NpcInteractionController | Interacción válida",
		" | NPC: ",
		npc_id,
		" | Servicio: ",
		service_id,
		" | Distancia: ",
		distance
	)


	interaction_requested.emit(
		npc_id,
		service_id
	)


	return true
