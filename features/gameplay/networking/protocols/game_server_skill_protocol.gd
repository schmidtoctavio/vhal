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

signal skill_learning_result_received(
	request_id: int,
	accepted: bool,
	skill_id: String,
	scroll_uid: String,
	reason: String,
	learned_skill_ids: PackedStringArray,
	idempotent: bool
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

const MESSAGE_SKILL_LEARNING_REQUEST: String = (
	"skill_learning_request"
)

const MESSAGE_SKILL_LEARNING_RESULT: String = (
	"skill_learning_result"
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

var next_skill_learning_request_id: int = 1

var latest_skill_learning_request_id: int = 0

var pending_skill_learning_by_request: Dictionary = {}

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
		message_type != MESSAGE_SKILL_CAST_RESULT
		and
		message_type != MESSAGE_SKILL_LEARNING_RESULT
	):
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El resultado de Skills recibido es inválido."
		)


		return true


	var data: Dictionary = (
		data_value
	)


	if message_type == MESSAGE_SKILL_CAST_RESULT:
		_process_skill_cast_result(
			data
		)


		return true


	_process_skill_learning_result(
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


	var normalized_target: Dictionary = {}


	if target_kind == "self":
		normalized_target = {
			"kind": "self",
		}


	elif target_kind == "entity":
		var entity_id_value: Variant = (
			target.get(
				"entity_id",
				null
			)
		)


		if typeof(entity_id_value) != TYPE_STRING:
			return ERR_INVALID_PARAMETER


		var entity_id := String(
			entity_id_value
		).strip_edges().to_lower()


		if entity_id.is_empty():
			return ERR_INVALID_PARAMETER


		if entity_id.length() > 96:
			return ERR_INVALID_PARAMETER


		normalized_target = {
			"kind": "entity",

			"entity_id": entity_id,
		}


	else:
		return ERR_INVALID_PARAMETER


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
# INTENCIÓN DE APRENDIZAJE
# =========================================================

func send_skill_learning_request(
	skill_id: String,
	scroll_uid: String
) -> Error:
	var normalized_skill_id := (
		skill_id
		.strip_edges()
		.to_lower()
	)


	var normalized_scroll_uid := (
		scroll_uid
		.strip_edges()
		.to_lower()
	)


	if (
		normalized_skill_id.is_empty()
		or
		normalized_skill_id.length() > 64
	):
		return ERR_INVALID_PARAMETER


	if (
		normalized_scroll_uid.is_empty()
		or
		normalized_scroll_uid.length() > 64
	):
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_skill_learning_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_SKILL_LEARNING_REQUEST,
			{
				"request_id": request_id,

				"skill_id": normalized_skill_id,

				"scroll_uid": normalized_scroll_uid,
			}
		)
	)


	if result != OK:
		return result as Error


	pending_skill_learning_by_request[
		request_id
	] = {
		"skill_id": normalized_skill_id,

		"scroll_uid": normalized_scroll_uid,
	}


	latest_skill_learning_request_id = (
		request_id
	)

	next_skill_learning_request_id += 1


	print(
		"GameServerClient | "
		+
		"Intención de aprendizaje enviada",
		" | Request: ",
		request_id,
		" | Skill: ",
		normalized_skill_id,
		" | Scroll UID: ",
		normalized_scroll_uid
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
# RESULTADO AUTORITATIVO DE APRENDIZAJE
# =========================================================

func _process_skill_learning_result(
	data: Dictionary
) -> void:
	# -----------------------------------------------------
	# REQUEST ID
	# -----------------------------------------------------

	var request_id := int(
		data.get(
			"request_id",
			0
		)
	)


	if request_id <= 0:
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"sin Request ID válido."
			)
		)


		return


	if not pending_skill_learning_by_request.has(
		request_id
	):
		_fail_connection(
			(
				"Se recibió un resultado de aprendizaje "
				+
				"desconocido."
			)
		)


		return


	var pending_value: Variant = (
		pending_skill_learning_by_request[
			request_id
		]
	)


	if typeof(pending_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Estado pendiente de aprendizaje inválido."
		)


		return


	var pending: Dictionary = (
		pending_value
	)


	# -----------------------------------------------------
	# SKILL ID
	# -----------------------------------------------------

	var skill_id_value: Variant = (
		data.get(
			"skill_id",
			null
		)
	)


	if typeof(skill_id_value) != TYPE_STRING:
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"sin Skill ID válido."
			)
		)


		return


	var skill_id := String(
		skill_id_value
	).strip_edges().to_lower()


	var expected_skill_id := String(
		pending.get(
			"skill_id",
			""
		)
	)


	if (
		skill_id.is_empty()
		or
		skill_id != expected_skill_id
	):
		_fail_connection(
			(
				"El resultado de aprendizaje "
				+
				"no corresponde a la Skill solicitada."
			)
		)


		return


	# -----------------------------------------------------
	# SCROLL UID
	# -----------------------------------------------------

	var scroll_uid_value: Variant = (
		data.get(
			"scroll_uid",
			null
		)
	)


	if typeof(scroll_uid_value) != TYPE_STRING:
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"sin Scroll UID válido."
			)
		)


		return


	var scroll_uid := String(
		scroll_uid_value
	).strip_edges().to_lower()


	var expected_scroll_uid := String(
		pending.get(
			"scroll_uid",
			""
		)
	)


	if (
		scroll_uid.is_empty()
		or
		scroll_uid != expected_scroll_uid
	):
		_fail_connection(
			(
				"El resultado de aprendizaje "
				+
				"no corresponde al Scroll solicitado."
			)
		)


		return


	# -----------------------------------------------------
	# ACCEPTED
	# -----------------------------------------------------

	var accepted_value: Variant = (
		data.get(
			"accepted",
			null
		)
	)


	if typeof(accepted_value) != TYPE_BOOL:
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"sin accepted válido."
			)
		)


		return


	var accepted: bool = (
		accepted_value
	)


	# -----------------------------------------------------
	# REASON
	# -----------------------------------------------------

	var reason_value: Variant = (
		data.get(
			"reason",
			null
		)
	)


	if typeof(reason_value) != TYPE_STRING:
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"sin reason válido."
			)
		)


		return


	var reason := String(
		reason_value
	).strip_edges()


	if reason.is_empty():
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"con reason vacío."
			)
		)


		return


	# -----------------------------------------------------
	# LEARNED SKILLS AUTORITATIVAS
	# -----------------------------------------------------

	var learned_skill_ids_value: Variant = (
		data.get(
			"learned_skill_ids",
			null
		)
	)


	if typeof(learned_skill_ids_value) != TYPE_ARRAY:
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"sin learned_skill_ids válidos."
			)
		)


		return


	var learned_skill_ids := PackedStringArray()

	var seen_skill_ids: Dictionary = {}


	for learned_skill_id_value: Variant in (
		learned_skill_ids_value as Array
	):
		if typeof(learned_skill_id_value) != TYPE_STRING:
			_fail_connection(
				(
					"Resultado de aprendizaje "
					+
					"con Skill aprendida inválida."
				)
			)


			return


		var learned_skill_id := String(
			learned_skill_id_value
		).strip_edges().to_lower()


		if (
			learned_skill_id.is_empty()
			or
			learned_skill_id.length() > 64
		):
			_fail_connection(
				(
					"Resultado de aprendizaje "
					+
					"con Skill aprendida inválida."
				)
			)


			return


		if seen_skill_ids.has(
			learned_skill_id
		):
			_fail_connection(
				(
					"Resultado de aprendizaje "
					+
					"con Skills duplicadas."
				)
			)


			return


		seen_skill_ids[
			learned_skill_id
		] = true


		learned_skill_ids.append(
			learned_skill_id
		)


	# -----------------------------------------------------
	# IDEMPOTENT
	# -----------------------------------------------------

	var idempotent_value: Variant = (
		data.get(
			"idempotent",
			null
		)
	)


	if typeof(idempotent_value) != TYPE_BOOL:
		_fail_connection(
			(
				"Resultado de aprendizaje "
				+
				"sin idempotent válido."
			)
		)


		return


	var idempotent: bool = (
		idempotent_value
	)


	pending_skill_learning_by_request.erase(
		request_id
	)


	print(
		"GameServerClient | "
		+
		"Resultado autoritativo de aprendizaje",
		" | Request: ",
		request_id,
		" | Skill: ",
		skill_id,
		" | Scroll UID: ",
		scroll_uid,
		" | Accepted: ",
		accepted,
		" | Reason: ",
		reason,
		" | Learned: ",
		learned_skill_ids,
		" | Idempotent: ",
		idempotent
	)


	skill_learning_result_received.emit(
		request_id,
		accepted,
		skill_id,
		scroll_uid,
		reason,
		learned_skill_ids,
		idempotent
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


	next_skill_learning_request_id = 1

	latest_skill_learning_request_id = 0

	pending_skill_learning_by_request.clear()
