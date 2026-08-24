class_name GameServerSkillProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal skill_cast_result_received(
	request_id: int,
	accepted: bool,
	skill_id: String,
	reason: String,
	vitals_snapshot: Dictionary,
	cooldown_remaining_seconds: float,
	effect: Dictionary
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_SKILL_CAST_REQUEST: String = (
	"skill_cast_request"
)

const MESSAGE_SKILL_CAST_RESULT: String = (
	"skill_cast_result"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var send_message: Callable = Callable()

var fail_connection: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var next_skill_cast_request_id: int = 1

var latest_skill_cast_request_id: int = 0

var pending_skill_id_by_request: Dictionary = {}


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
	if message_type != MESSAGE_SKILL_CAST_RESULT:
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El resultado de skill recibido es inválido."
		)


		return true


	var data: Dictionary = (
		data_value
	)


	_process_skill_cast_result(
		data
	)


	return true


# =========================================================
# INTENCIÓN DE CAST
# =========================================================

func send_skill_cast_request(
	skill_id: String,
	target: Dictionary
) -> Error:
	var normalized_skill_id := (
		skill_id
		.strip_edges()
		.to_lower()
	)


	if normalized_skill_id.is_empty():
		return ERR_INVALID_PARAMETER


	if normalized_skill_id.length() > 64:
		return ERR_INVALID_PARAMETER


	var target_kind := String(
		target.get(
			"kind",
			""
		)
	).strip_edges().to_lower()


	if target_kind.is_empty():
		return ERR_INVALID_PARAMETER


	var normalized_target := (
		target.duplicate(
			true
		)
	)


	normalized_target[
		"kind"
	] = target_kind


	var request_id := (
		next_skill_cast_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_SKILL_CAST_REQUEST,
			{
				"request_id": request_id,

				"skill_id": normalized_skill_id,

				"target": normalized_target,
			}
		)
	)


	if result != OK:
		return result as Error


	pending_skill_id_by_request[
		request_id
	] = normalized_skill_id


	latest_skill_cast_request_id = request_id

	next_skill_cast_request_id += 1


	print(
		"GameServerClient | Intención de cast enviada",
		" | Request: ",
		request_id,
		" | Skill: ",
		normalized_skill_id,
		" | Target: ",
		target_kind
	)


	return OK


# =========================================================
# RESULTADO AUTORITATIVO
# =========================================================

func _process_skill_cast_result(
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
			"Resultado de skill sin Request ID válido."
		)


		return


	if not pending_skill_id_by_request.has(
		request_id
	):
		_fail_connection(
			"Se recibió un resultado de skill desconocido."
		)


		return


	var skill_id_value: Variant = (
		data.get(
			"skill_id",
			null
		)
	)


	if typeof(skill_id_value) != TYPE_STRING:
		_fail_connection(
			"Resultado de skill sin Skill ID válido."
		)


		return


	var skill_id := String(
		skill_id_value
	).strip_edges().to_lower()


	var expected_skill_id := String(
		pending_skill_id_by_request[
			request_id
		]
	)


	if skill_id != expected_skill_id:
		_fail_connection(
			"El resultado no corresponde a la skill solicitada."
		)


		return


	var accepted_value: Variant = (
		data.get(
			"accepted",
			null
		)
	)


	if typeof(accepted_value) != TYPE_BOOL:
		_fail_connection(
			"Resultado de skill sin estado accepted válido."
		)


		return


	var accepted: bool = (
		accepted_value
	)


	var reason_value: Variant = (
		data.get(
			"reason",
			null
		)
	)


	if typeof(reason_value) != TYPE_STRING:
		_fail_connection(
			"Resultado de skill sin reason válido."
		)


		return


	var reason := String(
		reason_value
	).strip_edges()


	if reason.is_empty():
		_fail_connection(
			"Resultado de skill con reason vacío."
		)


		return


	var vitals_value: Variant = (
		data.get(
			"vitals",
			null
		)
	)


	if typeof(vitals_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Resultado de skill sin vitals válidos."
		)


		return


	var vitals_snapshot: Dictionary = (
		vitals_value as Dictionary
	).duplicate(
		true
	)


	var cooldown_value: Variant = (
		data.get(
			"cooldown_remaining_seconds",
			null
		)
	)


	if (
		typeof(cooldown_value) != TYPE_FLOAT
		and
		typeof(cooldown_value) != TYPE_INT
	):
		_fail_connection(
			"Resultado de skill con cooldown inválido."
		)


		return


	var cooldown_remaining_seconds := float(
		cooldown_value
	)


	if cooldown_remaining_seconds < 0.0:
		_fail_connection(
			"Resultado de skill con cooldown negativo."
		)


		return


	var effect_value: Variant = (
		data.get(
			"effect",
			null
		)
	)


	if typeof(effect_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Resultado de skill sin effect válido."
		)


		return


	var effect: Dictionary = (
		effect_value as Dictionary
	).duplicate(
		true
	)


	pending_skill_id_by_request.erase(
		request_id
	)


	print(
		"GameServerClient | Resultado autoritativo de cast",
		" | Request: ",
		request_id,
		" | Skill: ",
		skill_id,
		" | Accepted: ",
		accepted,
		" | Reason: ",
		reason,
		" | Cooldown: ",
		cooldown_remaining_seconds
	)


	skill_cast_result_received.emit(
		request_id,
		accepted,
		skill_id,
		reason,
		vitals_snapshot,
		cooldown_remaining_seconds,
		effect
	)


# =========================================================
# ERROR
# =========================================================

func _fail_connection(
	message: String
) -> void:
	if not fail_connection.is_valid():
		return


	fail_connection.call(
		message
	)


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	next_skill_cast_request_id = 1

	latest_skill_cast_request_id = 0

	pending_skill_id_by_request.clear()
