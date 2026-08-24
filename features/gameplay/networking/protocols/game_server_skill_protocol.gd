class_name GameServerSkillProtocol
extends RefCounted


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_SKILL_CAST_REQUEST: String = (
	"skill_cast_request"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var send_message: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var next_skill_cast_request_id: int = 1

var latest_skill_cast_request_id: int = 0


# =========================================================
# SETUP
# =========================================================

func setup(
	p_send_message: Callable
) -> bool:
	if not p_send_message.is_valid():
		return false


	send_message = p_send_message


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
# RESET
# =========================================================

func reset() -> void:
	next_skill_cast_request_id = 1

	latest_skill_cast_request_id = 0
