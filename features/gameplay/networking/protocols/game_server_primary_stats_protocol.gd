class_name GameServerPrimaryStatsProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal primary_stat_allocation_result_received(
	request_id: int,
	accepted: bool,
	stat_id: String,
	points: int,
	reason: String,
	primary_stats_snapshot: Dictionary
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_PRIMARY_STAT_ALLOCATION_REQUEST: String = (
	"primary_stat_allocation_request"
)

const MESSAGE_PRIMARY_STAT_ALLOCATION_RESULT: String = (
	"primary_stat_allocation_result"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var send_message: Callable = Callable()

var fail_connection: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var next_request_id: int = 1

var pending_by_request: Dictionary = {}


# =========================================================
# SETUP
# =========================================================

func setup(
	p_send_message: Callable,
	p_fail_connection: Callable
) -> bool:
	if not p_send_message.is_valid():
		return false


	if not p_fail_connection.is_valid():
		return false


	send_message = p_send_message

	fail_connection = p_fail_connection


	return true


# =========================================================
# PROCESAR MENSAJE
# =========================================================

func process_message(
	message_type: String,
	data_value: Variant
) -> bool:
	if (
		message_type
		!=
		MESSAGE_PRIMARY_STAT_ALLOCATION_RESULT
	):
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El resultado de Primary Stat Allocation es inválido."
		)


		return true


	_process_allocation_result(
		data_value
	)


	return true


# =========================================================
# ENVIAR INTENCIÓN
# =========================================================

func send_allocation_request(
	stat_id: String,
	points: int
) -> Error:
	var normalized_stat_id := (
		stat_id
		.strip_edges()
		.to_lower()
	)


	if not _is_valid_stat_id(
		normalized_stat_id
	):
		return ERR_INVALID_PARAMETER


	if points <= 0:
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_PRIMARY_STAT_ALLOCATION_REQUEST,
			{
				"request_id": request_id,

				"stat_id": normalized_stat_id,

				"points": points,
			}
		)
	)


	if result != OK:
		return result as Error


	pending_by_request[
		request_id
	] = {
		"stat_id": normalized_stat_id,

		"points": points,
	}


	next_request_id += 1


	print(
		"GameServerClient | "
		+
		"Intención de Primary Stat Allocation enviada",
		" | Request: ",
		request_id,
		" | Stat: ",
		normalized_stat_id,
		" | Points: ",
		points
	)


	return OK


# =========================================================
# RESULTADO AUTORITATIVO
# =========================================================

func _process_allocation_result(
	data: Dictionary
) -> void:
	var request_id := int(
		data.get(
			"request_id",
			0
		)
	)


	if request_id <= 0:
		_fail_connection(
			"Stat Allocation Result sin Request ID válido."
		)


		return


	if not pending_by_request.has(
		request_id
	):
		_fail_connection(
			"Se recibió un Stat Allocation Result desconocido."
		)


		return


	var pending_value: Variant = (
		pending_by_request[
			request_id
		]
	)


	if typeof(pending_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El estado pendiente de Stat Allocation es inválido."
		)


		return


	var pending: Dictionary = (
		pending_value
	)


	# =====================================================
	# STAT ID
	# =====================================================

	var stat_id_value: Variant = (
		data.get(
			"stat_id",
			null
		)
	)


	if typeof(stat_id_value) != TYPE_STRING:
		_fail_connection(
			"Stat Allocation Result sin Stat ID válido."
		)


		return


	var stat_id := String(
		stat_id_value
	).strip_edges().to_lower()


	var expected_stat_id := String(
		pending.get(
			"stat_id",
			""
		)
	)


	if (
		not _is_valid_stat_id(
			stat_id
		)
		or
		stat_id != expected_stat_id
	):
		_fail_connection(
			"El Stat Allocation Result no corresponde al Stat solicitado."
		)


		return


	# =====================================================
	# POINTS
	# =====================================================

	var points_value: Variant = (
		data.get(
			"points",
			null
		)
	)


	if (
		typeof(points_value) != TYPE_INT
		and
		typeof(points_value) != TYPE_FLOAT
	):
		_fail_connection(
			"Stat Allocation Result con Points inválidos."
		)


		return


	var points := int(
		points_value
	)


	var expected_points := int(
		pending.get(
			"points",
			0
		)
	)


	if (
		points <= 0
		or
		points != expected_points
	):
		_fail_connection(
			"El Stat Allocation Result no corresponde a los Points solicitados."
		)


		return


	# =====================================================
	# ACCEPTED
	# =====================================================

	var accepted_value: Variant = (
		data.get(
			"accepted",
			null
		)
	)


	if typeof(accepted_value) != TYPE_BOOL:
		_fail_connection(
			"Stat Allocation Result sin accepted válido."
		)


		return


	var accepted: bool = (
		accepted_value
	)


	# =====================================================
	# REASON
	# =====================================================

	var reason_value: Variant = (
		data.get(
			"reason",
			null
		)
	)


	if typeof(reason_value) != TYPE_STRING:
		_fail_connection(
			"Stat Allocation Result sin reason válido."
		)


		return


	var reason := String(
		reason_value
	).strip_edges()


	if reason.is_empty():
		_fail_connection(
			"Stat Allocation Result con reason vacío."
		)


		return


	# =====================================================
	# PRIMARY STATS AUTORITATIVOS
	# =====================================================

	var primary_stats_value: Variant = (
		data.get(
			"primary_stats",
			null
		)
	)


	if typeof(primary_stats_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Stat Allocation Result sin Primary Stats válidos."
		)


		return


	var primary_stats_snapshot: Dictionary = (
		primary_stats_value
	)


	var validation_state := (
		PrimaryStatsState.new()
	)


	if not validation_state.apply_snapshot(
		primary_stats_snapshot
	):
		_fail_connection(
			"Stat Allocation Result contiene Primary Stats inválidos."
		)


		return


	# -----------------------------------------------------
	# Recién ahora podemos retirar el pending.
	# -----------------------------------------------------

	pending_by_request.erase(
		request_id
	)


	print(
		"GameServerClient | "
		+
		"Resultado autoritativo de Primary Stat Allocation",
		" | Request: ",
		request_id,
		" | Stat: ",
		stat_id,
		" | Points: ",
		points,
		" | Accepted: ",
		accepted,
		" | Reason: ",
		reason,
		" | Revision: ",
		validation_state.revision,
		" | STR allocated: ",
		validation_state.allocated_strength,
		" | Unspent: ",
		validation_state.unspent_points
	)


	primary_stat_allocation_result_received.emit(
		request_id,
		accepted,
		stat_id,
		points,
		reason,
		primary_stats_snapshot.duplicate(
			true
		)
	)


# =========================================================
# VALIDAR STAT ID
# =========================================================

func _is_valid_stat_id(
	stat_id: String
) -> bool:
	return (
		stat_id == "strength"
		or
		stat_id == "agility"
		or
		stat_id == "vitality"
		or
		stat_id == "energy"
	)


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	next_request_id = 1

	pending_by_request.clear()


# =========================================================
# FAIL
# =========================================================

func _fail_connection(
	message: String
) -> void:
	if not fail_connection.is_valid():
		return


	fail_connection.call(
		message
	)
