class_name GameServerCombatProtocol
extends RefCounted


signal basic_attack_result_received(
	request_id: int,
	accepted: bool,
	reason: String,
	target: Dictionary,
	attack_profile: Dictionary
)


const MESSAGE_BASIC_ATTACK_REQUEST: String = (
	"basic_attack_request"
)

const MESSAGE_BASIC_ATTACK_RESULT: String = (
	"basic_attack_result"
)


var send_message: Callable = Callable()

var fail_connection: Callable = Callable()


var next_basic_attack_request_id: int = 1

var pending_entity_id_by_request: Dictionary = {}


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


func process_message(
	message_type: String,
	data_value: Variant
) -> bool:
	if (
		message_type
		!=
		MESSAGE_BASIC_ATTACK_RESULT
	):
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El resultado de Basic Attack es inválido."
		)


		return true


	_process_basic_attack_result(
		data_value as Dictionary
	)


	return true


func send_basic_attack_request(
	target: Dictionary
) -> Error:
	var target_kind := String(
		target.get(
			"kind",
			""
		)
	).strip_edges().to_lower()


	if target_kind != "entity":
		return ERR_INVALID_PARAMETER


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


	var request_id := (
		next_basic_attack_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_BASIC_ATTACK_REQUEST,
			{
				"request_id": request_id,

				"target": {
					"kind": "entity",

					"entity_id": entity_id,
				},
			}
		)
	)


	if result != OK:
		return result as Error


	pending_entity_id_by_request[
		request_id
	] = entity_id


	next_basic_attack_request_id += 1


	print(
		"GameServerClient | Intención de Basic Attack enviada",
		" | Request: ",
		request_id,
		" | Entity: ",
		entity_id
	)


	return OK


func _process_basic_attack_result(
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
			"Basic Attack result sin Request ID válido."
		)


		return


	if not pending_entity_id_by_request.has(
		request_id
	):
		_fail_connection(
			"Resultado de Basic Attack desconocido."
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
			"Basic Attack result sin accepted válido."
		)


		return


	var accepted: bool = accepted_value


	var reason_value: Variant = (
		data.get(
			"reason",
			null
		)
	)


	if typeof(reason_value) != TYPE_STRING:
		_fail_connection(
			"Basic Attack result sin reason válido."
		)


		return


	var reason := String(
		reason_value
	).strip_edges()


	if reason.is_empty():
		_fail_connection(
			"Basic Attack result con reason vacío."
		)


		return


	var target_value: Variant = (
		data.get(
			"target",
			null
		)
	)


	if typeof(target_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Basic Attack result sin target válido."
		)


		return


	var target: Dictionary = (
		target_value as Dictionary
	).duplicate(true)


	var entity_id := String(
		target.get(
			"entity_id",
			""
		)
	).strip_edges().to_lower()


	var expected_entity_id := String(
		pending_entity_id_by_request[
			request_id
		]
	)


	if entity_id != expected_entity_id:
		_fail_connection(
			"El resultado de Basic Attack no corresponde al target solicitado."
		)


		return


	var profile_value: Variant = (
		data.get(
			"attack_profile",
			null
		)
	)


	if typeof(profile_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Basic Attack result sin attack_profile válido."
		)


		return


	var attack_profile: Dictionary = (
		profile_value as Dictionary
	).duplicate(true)


	var attack_mode := String(
		attack_profile.get(
			"mode",
			""
		)
	).strip_edges().to_lower()


	if (
		attack_mode != "unarmed"
		and
		attack_mode != "melee"
		and
		attack_mode != "ranged"
	):
		_fail_connection(
			"Basic Attack result con mode inválido."
		)


		return


	pending_entity_id_by_request.erase(
		request_id
	)


	print(
		"GameServerClient | Resultado autoritativo de Basic Attack",
		" | Request: ",
		request_id,
		" | Entity: ",
		entity_id,
		" | Accepted: ",
		accepted,
		" | Reason: ",
		reason,
		" | Mode: ",
		attack_mode,
		" | Weapon: ",
		String(
			attack_profile.get(
				"weapon_item_id",
				""
			)
		)
	)


	basic_attack_result_received.emit(
		request_id,
		accepted,
		reason,
		target,
		attack_profile
	)


func _fail_connection(
	message: String
) -> void:
	if not fail_connection.is_valid():
		return


	fail_connection.call(
		message
	)


func reset() -> void:
	next_basic_attack_request_id = 1

	pending_entity_id_by_request.clear()
