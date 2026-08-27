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

signal skill_trainer_offers_received(
	snapshot: Dictionary
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

const MESSAGE_SKILL_TRAINER_OFFERS: String = (
	"skill_trainer_offers"
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
		and
		message_type != MESSAGE_SKILL_TRAINER_OFFERS
	):
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El mensaje de Skills recibido es inválido."
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


	if message_type == MESSAGE_SKILL_LEARNING_RESULT:
		_process_skill_learning_result(
			data
		)


		return true


	_process_skill_trainer_offers(
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
# OFERTAS AUTORITATIVAS DEL SKILL TRAINER
# =========================================================

func _process_skill_trainer_offers(
	data: Dictionary
) -> void:
	# -----------------------------------------------------
	# CHARACTER
	# -----------------------------------------------------

	var character_id := int(
		data.get(
			"character_id",
			0
		)
	)


	if character_id <= 0:
		_fail_connection(
			"Trainer Offers sin Character ID válido."
		)


		return


	# -----------------------------------------------------
	# NPC
	# -----------------------------------------------------

	var npc_id_value: Variant = (
		data.get(
			"npc_id",
			null
		)
	)


	if typeof(npc_id_value) != TYPE_STRING:
		_fail_connection(
			"Trainer Offers sin NPC ID válido."
		)


		return


	var npc_id := String(
		npc_id_value
	).strip_edges().to_lower()


	if (
		npc_id.is_empty()
		or
		npc_id.length() > 64
	):
		_fail_connection(
			"Trainer Offers con NPC ID inválido."
		)


		return


	# -----------------------------------------------------
	# SERVICE
	# -----------------------------------------------------

	var service_id_value: Variant = (
		data.get(
			"service_id",
			null
		)
	)


	if typeof(service_id_value) != TYPE_STRING:
		_fail_connection(
			"Trainer Offers sin Service ID válido."
		)


		return


	var service_id := String(
		service_id_value
	).strip_edges().to_lower()


	if service_id != "skill_trainer":
		_fail_connection(
			"Trainer Offers recibido desde un servicio inválido."
		)


		return


	# -----------------------------------------------------
	# CLASS
	# -----------------------------------------------------

	var class_id_value: Variant = (
		data.get(
			"class_id",
			null
		)
	)


	if typeof(class_id_value) != TYPE_STRING:
		_fail_connection(
			"Trainer Offers sin Class ID válido."
		)


		return


	var class_id := String(
		class_id_value
	).strip_edges().to_lower()


	if (
		class_id.is_empty()
		or
		class_id.length() > 64
	):
		_fail_connection(
			"Trainer Offers con Class ID inválido."
		)


		return


	# -----------------------------------------------------
	# LEVEL
	# -----------------------------------------------------

	var level := int(
		data.get(
			"level",
			0
		)
	)


	if level <= 0:
		_fail_connection(
			"Trainer Offers con nivel inválido."
		)


		return


	# -----------------------------------------------------
	# OFFERS
	# -----------------------------------------------------

	var offers_value: Variant = (
		data.get(
			"offers",
			null
		)
	)


	if typeof(offers_value) != TYPE_ARRAY:
		_fail_connection(
			"Trainer Offers sin Array de ofertas válido."
		)


		return


	var normalized_offers: Array[Dictionary] = []

	var seen_skill_ids: Dictionary = {}


	for offer_value: Variant in (
		offers_value as Array
	):
		if typeof(offer_value) != TYPE_DICTIONARY:
			_fail_connection(
				"Trainer Offers contiene una oferta inválida."
			)


			return


		var offer: Dictionary = (
			offer_value as Dictionary
		)


		# -------------------------------------------------
		# SKILL
		# -------------------------------------------------

		var skill_id_value: Variant = (
			offer.get(
				"skill_id",
				null
			)
		)


		if typeof(skill_id_value) != TYPE_STRING:
			_fail_connection(
				"Trainer Offer sin Skill ID válido."
			)


			return


		var skill_id := String(
			skill_id_value
		).strip_edges().to_lower()


		if (
			skill_id.is_empty()
			or
			skill_id.length() > 64
		):
			_fail_connection(
				"Trainer Offer con Skill ID inválido."
			)


			return


		if seen_skill_ids.has(
			skill_id
		):
			_fail_connection(
				"Trainer Offers contiene Skills duplicadas."
			)


			return


		if ClientSkillCatalog.get_definition(
			skill_id
		) == null:
			_fail_connection(
				(
					"Trainer Offer referencia una Skill "
					+
					"desconocida por el cliente: %s"
				)
				%
				skill_id
			)


			return


		seen_skill_ids[
			skill_id
		] = true


		# -------------------------------------------------
		# SCROLL ITEM
		# -------------------------------------------------

		var scroll_item_id_value: Variant = (
			offer.get(
				"scroll_item_id",
				null
			)
		)


		if typeof(scroll_item_id_value) != TYPE_STRING:
			_fail_connection(
				"Trainer Offer sin Scroll Item ID válido."
			)


			return


		var scroll_item_id := String(
			scroll_item_id_value
		).strip_edges().to_lower()


		if (
			scroll_item_id.is_empty()
			or
			scroll_item_id.length() > 64
		):
			_fail_connection(
				"Trainer Offer con Scroll Item ID inválido."
			)


			return


		if ItemCatalog.get_definition(
			scroll_item_id
		) == null:
			_fail_connection(
				(
					"Trainer Offer referencia un Scroll "
					+
					"desconocido por el cliente: %s"
				)
				%
				scroll_item_id
			)


			return


		# -------------------------------------------------
		# SCROLL UID
		# -------------------------------------------------

		var scroll_uid_value: Variant = (
			offer.get(
				"scroll_uid",
				null
			)
		)


		if typeof(scroll_uid_value) != TYPE_STRING:
			_fail_connection(
				"Trainer Offer sin Scroll UID válido."
			)


			return


		var scroll_uid := String(
			scroll_uid_value
		).strip_edges().to_lower()


		if scroll_uid.length() > 64:
			_fail_connection(
				"Trainer Offer con Scroll UID inválido."
			)


			return


		# -------------------------------------------------
		# MINIMUM LEVEL
		# -------------------------------------------------

		var minimum_level := int(
			offer.get(
				"minimum_level",
				0
			)
		)


		if minimum_level <= 0:
			_fail_connection(
				"Trainer Offer con nivel mínimo inválido."
			)


			return


		# -------------------------------------------------
		# FLAGS
		# -------------------------------------------------

		var already_learned_value: Variant = (
			offer.get(
				"already_learned",
				null
			)
		)


		var level_requirement_met_value: Variant = (
			offer.get(
				"level_requirement_met",
				null
			)
		)


		var has_scroll_value: Variant = (
			offer.get(
				"has_scroll",
				null
			)
		)


		var can_learn_value: Variant = (
			offer.get(
				"can_learn",
				null
			)
		)


		if (
			typeof(already_learned_value) != TYPE_BOOL
			or
			typeof(level_requirement_met_value) != TYPE_BOOL
			or
			typeof(has_scroll_value) != TYPE_BOOL
			or
			typeof(can_learn_value) != TYPE_BOOL
		):
			_fail_connection(
				"Trainer Offer contiene flags inválidos."
			)


			return


		var already_learned: bool = (
			already_learned_value
		)


		var level_requirement_met: bool = (
			level_requirement_met_value
		)


		var has_scroll: bool = (
			has_scroll_value
		)


		var can_learn: bool = (
			can_learn_value
		)


		# -------------------------------------------------
		# CONSISTENCIA DEL SCROLL
		# -------------------------------------------------

		if (
			has_scroll
			!=
			not scroll_uid.is_empty()
		):
			_fail_connection(
				"Trainer Offer posee estado de Scroll inconsistente."
			)


			return


		# -------------------------------------------------
		# CAN LEARN
		#
		# Esto NO vuelve autoridad al cliente.
		# Sólo comprueba que el paquete no sea internamente
		# contradictorio.
		# -------------------------------------------------

		var expected_can_learn := (
			not already_learned
			and
			level_requirement_met
			and
			has_scroll
		)


		if can_learn != expected_can_learn:
			_fail_connection(
				"Trainer Offer posee can_learn inconsistente."
			)


			return


		# -------------------------------------------------
		# REASON
		# -------------------------------------------------

		var reason_value: Variant = (
			offer.get(
				"reason",
				null
			)
		)


		if typeof(reason_value) != TYPE_STRING:
			_fail_connection(
				"Trainer Offer sin reason válido."
			)


			return


		var reason := String(
			reason_value
		).strip_edges().to_lower()


		if (
			reason.is_empty()
			or
			reason.length() > 64
		):
			_fail_connection(
				"Trainer Offer con reason inválido."
			)


			return


		var expected_reason := "ok"


		if already_learned:
			expected_reason = "skill_already_learned"

		elif not level_requirement_met:
			expected_reason = "level_requirement_not_met"

		elif not has_scroll:
			expected_reason = "scroll_required"


		if reason != expected_reason:
			_fail_connection(
				"Trainer Offer posee reason inconsistente."
			)


			return


		normalized_offers.append(
			{
				"skill_id": skill_id,

				"scroll_item_id": scroll_item_id,

				"scroll_uid": scroll_uid,

				"minimum_level": minimum_level,

				"already_learned": already_learned,

				"level_requirement_met": (
					level_requirement_met
				),

				"has_scroll": has_scroll,

				"can_learn": can_learn,

				"reason": reason,
			}
		)


	# -----------------------------------------------------
	# SNAPSHOT NORMALIZADO
	# -----------------------------------------------------

	var snapshot := {
		"character_id": character_id,

		"npc_id": npc_id,

		"service_id": service_id,

		"class_id": class_id,

		"level": level,

		"offers": normalized_offers,
	}


	print(
		"GameServerClient | "
		+
		"Ofertas autoritativas del Skill Trainer recibidas",
		" | Character ID: ",
		character_id,
		" | NPC: ",
		npc_id,
		" | Clase: ",
		class_id,
		" | Nivel: ",
		level,
		" | Ofertas: ",
		normalized_offers.size()
	)


	for offer: Dictionary in normalized_offers:
		print(
			"GameServerClient | Trainer Offer recibido",
			" | Skill: ",
			offer.get("skill_id", ""),
			" | Scroll: ",
			offer.get("scroll_item_id", ""),
			" | Has Scroll: ",
			offer.get("has_scroll", false),
			" | Can Learn: ",
			offer.get("can_learn", false),
			" | Reason: ",
			offer.get("reason", "")
		)


	skill_trainer_offers_received.emit(
		snapshot
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
