class_name GameServerNpcProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal npc_interaction_decision_received(
	request_id: int,
	accepted: bool,
	npc_id: String,
	service_id: String,
	reason: String
)

signal npc_service_ended_received(
	npc_id: String,
	service_id: String,
	reason: String
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_NPC_INTERACTION_REQUEST: String = (
	"npc_interaction_request"
)

const MESSAGE_NPC_INTERACTION_DECISION: String = (
	"npc_interaction_decision"
)

const MESSAGE_NPC_SERVICE_END_REQUEST: String = (
	"npc_service_end_request"
)

const MESSAGE_NPC_SERVICE_ENDED: String = (
	"npc_service_ended"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var send_message: Callable = Callable()

var get_local_peer_id: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var next_npc_interaction_request_id: int = 1

var latest_npc_interaction_request_id: int = 0


# =========================================================
# SETUP
# =========================================================

func setup(
	p_send_message: Callable,
	p_get_local_peer_id: Callable
) -> bool:
	if not p_send_message.is_valid():
		return false


	if not p_get_local_peer_id.is_valid():
		return false


	send_message = p_send_message

	get_local_peer_id = p_get_local_peer_id


	return true


# =========================================================
# PROCESAR MENSAJE
# =========================================================

func process_message(
	message_type: String,
	data_value: Variant
) -> bool:
	match message_type:
		MESSAGE_NPC_INTERACTION_DECISION:
			if typeof(data_value) == TYPE_DICTIONARY:
				var decision_data: Dictionary = (
					data_value
				)


				_process_npc_interaction_decision(
					decision_data
				)


			return true

		MESSAGE_NPC_SERVICE_ENDED:
			if typeof(data_value) == TYPE_DICTIONARY:
				var service_end_data: Dictionary = (
					data_value
				)


				_process_npc_service_ended(
					service_end_data
				)


			return true


	return false


# =========================================================
# INTERACCIÓN NPC
# =========================================================

func send_npc_interaction_request(
	npc_id: String
) -> Error:
	var normalized_npc_id := (
		npc_id.strip_edges()
	)


	if normalized_npc_id.is_empty():
		return ERR_INVALID_PARAMETER


	if normalized_npc_id.length() > 64:
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_npc_interaction_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_NPC_INTERACTION_REQUEST,
			{
				"request_id": request_id,
				"npc_id": normalized_npc_id,
			}
		)
	)


	if result != OK:
		return result as Error


	latest_npc_interaction_request_id = (
		request_id
	)


	next_npc_interaction_request_id += 1


	print(
		"GameServerClient | Solicitud de interacción NPC enviada",
		" | Request: ",
		request_id,
		" | NPC: ",
		normalized_npc_id
	)


	return OK


# =========================================================
# DECISIÓN AUTORITATIVA DE INTERACCIÓN NPC
# =========================================================

func _process_npc_interaction_decision(
	data: Dictionary
) -> void:
	var decision_peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if (
		decision_peer_id
		!=
		int(
			get_local_peer_id.call()
		)
	):
		return


	var request_id := int(
		data.get(
			"request_id",
			0
		)
	)


	if request_id <= 0:
		return


	if (
		request_id
		!=
		latest_npc_interaction_request_id
	):
		return


	var accepted := bool(
		data.get(
			"accepted",
			false
		)
	)


	var npc_id := String(
		data.get(
			"npc_id",
			""
		)
	).strip_edges()


	if npc_id.is_empty():
		return


	var service_id := String(
		data.get(
			"service_id",
			""
		)
	).strip_edges()


	var reason := String(
		data.get(
			"reason",
			""
		)
	).strip_edges()


	if (
		accepted
		and
		service_id.is_empty()
	):
		return


	print(
		"GameServerClient | Decisión de interacción NPC",
		" | Request: ",
		request_id,
		" | Accepted: ",
		accepted,
		" | NPC: ",
		npc_id,
		" | Servicio: ",
		service_id,
		" | Motivo: ",
		reason
	)


	npc_interaction_decision_received.emit(
		request_id,
		accepted,
		npc_id,
		service_id,
		reason
	)


# =========================================================
# FINALIZAR SERVICIO NPC
# =========================================================

func send_npc_service_end_request() -> Error:
	var result := int(
		send_message.call(
			MESSAGE_NPC_SERVICE_END_REQUEST,
			{}
		)
	)


	if result != OK:
		return result as Error


	print(
		"GameServerClient | Solicitud de cierre de servicio NPC enviada."
	)


	return OK


# =========================================================
# SERVICIO NPC FINALIZADO POR SERVIDOR
# =========================================================

func _process_npc_service_ended(
	data: Dictionary
) -> void:
	var npc_id := String(
		data.get(
			"npc_id",
			""
		)
	).strip_edges()


	var service_id := String(
		data.get(
			"service_id",
			""
		)
	).strip_edges()


	var reason := String(
		data.get(
			"reason",
			""
		)
	).strip_edges()


	if npc_id.is_empty():
		return


	if service_id.is_empty():
		return


	if reason.is_empty():
		return


	print(
		"GameServerClient | Servicio NPC finalizado por servidor",
		" | NPC: ",
		npc_id,
		" | Servicio: ",
		service_id,
		" | Motivo: ",
		reason
	)


	npc_service_ended_received.emit(
		npc_id,
		service_id,
		reason
	)


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	next_npc_interaction_request_id = 1

	latest_npc_interaction_request_id = 0
