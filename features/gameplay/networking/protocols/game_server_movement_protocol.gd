class_name GameServerMovementProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal authoritative_movement_state_received(
	position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
)

signal remote_player_movement_state_received(
	peer_id: int,
	position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
)

signal movement_decision_received(
	request_id: int,
	accepted: bool,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	authorized_target: Vector3,
	reason: String
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_MOVE_REQUEST: String = (
	"move_request"
)

const MESSAGE_MOVEMENT_STATE: String = (
	"movement_state"
)

const MESSAGE_MOVEMENT_DECISION: String = (
	"movement_decision"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var send_message: Callable = Callable()

var get_local_peer_id: Callable = Callable()

var presence_protocol: GameServerPresenceProtocol = null


# =========================================================
# ESTADO
# =========================================================

var latest_movement_sequence: int = 0

var latest_authoritative_position: Vector3 = (
	Vector3.ZERO
)

var latest_authoritative_rotation_y: float = 0.0

var latest_authoritative_moving: bool = false

var next_move_request_id: int = 1

var latest_move_request_id: int = 0

var remote_movement_sequences: Dictionary = {}


# =========================================================
# SETUP
# =========================================================

func setup(
	p_send_message: Callable,
	p_get_local_peer_id: Callable,
	p_presence_protocol: GameServerPresenceProtocol
) -> bool:
	if not p_send_message.is_valid():
		return false


	if not p_get_local_peer_id.is_valid():
		return false


	if p_presence_protocol == null:
		return false


	send_message = p_send_message

	get_local_peer_id = p_get_local_peer_id

	presence_protocol = p_presence_protocol


	return true


# =========================================================
# PROCESAR MENSAJE
# =========================================================

func process_message(
	message_type: String,
	data_value: Variant
) -> bool:
	match message_type:
		MESSAGE_MOVEMENT_STATE:
			if typeof(data_value) == TYPE_DICTIONARY:
				var movement_data: Dictionary = (
					data_value
				)


				_process_movement_state(
					movement_data
				)


			return true

		MESSAGE_MOVEMENT_DECISION:
			if typeof(data_value) == TYPE_DICTIONARY:
				var decision_data: Dictionary = (
					data_value
				)


				_process_movement_decision(
					decision_data
				)


			return true


	return false


# =========================================================
# INTENCIÓN DE MOVIMIENTO
# =========================================================

func send_move_request(
	target: Vector3
) -> Error:
	var request_id := (
		next_move_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_MOVE_REQUEST,
			{
				"request_id": request_id,

				"target": {
					"x": target.x,
					"y": target.y,
					"z": target.z,
				},
			}
		)
	)


	if result != OK:
		return result as Error


	latest_move_request_id = (
		request_id
	)


	next_move_request_id += 1


	print(
		"GameServerClient | Intención de movimiento enviada",
		" | Request: ",
		request_id,
		" | Destino: ",
		target
	)


	return OK


# =========================================================
# ESTADO AUTORITATIVO DE MOVIMIENTO
# =========================================================

func _process_movement_state(
	data: Dictionary
) -> void:
	var state_peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if state_peer_id <= 1:
		return


	var sequence := int(
		data.get(
			"sequence",
			0
		)
	)


	if sequence <= 0:
		return


	var position_value: Variant = (
		data.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		return


	var position_data: Dictionary = (
		position_value
	)


	if (
		not position_data.has("x")
		or
		not position_data.has("y")
		or
		not position_data.has("z")
	):
		return


	var authoritative_position := Vector3(
		float(
			position_data["x"]
		),
		float(
			position_data["y"]
		),
		float(
			position_data["z"]
		)
	)


	var authoritative_rotation_y := float(
		data.get(
			"rotation_y",
			0.0
		)
	)


	var moving := bool(
		data.get(
			"moving",
			false
		)
	)


	var local_peer_id := int(
		get_local_peer_id.call()
	)


	# -----------------------------------------------------
	# PLAYER LOCAL
	# -----------------------------------------------------

	if state_peer_id == local_peer_id:
		if sequence <= latest_movement_sequence:
			return


		latest_movement_sequence = sequence

		latest_authoritative_position = (
			authoritative_position
		)

		latest_authoritative_rotation_y = (
			authoritative_rotation_y
		)

		latest_authoritative_moving = moving


		print(
			"GameServerClient | Movimiento autoritativo recibido",
			" | Seq: ",
			sequence,
			" | Posición: ",
			authoritative_position,
			" | Moving: ",
			moving
		)


		authoritative_movement_state_received.emit(
			authoritative_position,
			authoritative_rotation_y,
			moving,
			sequence
		)


		return


	# -----------------------------------------------------
	# PLAYER REMOTO
	# -----------------------------------------------------

	if not presence_protocol.has_remote_player(
		state_peer_id
	):
		return


	var previous_sequence := int(
		remote_movement_sequences.get(
			state_peer_id,
			0
		)
	)


	if sequence <= previous_sequence:
		return


	remote_movement_sequences[
		state_peer_id
	] = sequence


	# -----------------------------------------------------
	# ACTUALIZAR TAMBIÉN EL CACHE DE PRESENCIA
	# -----------------------------------------------------

	presence_protocol.update_remote_world_state(
		state_peer_id,
		authoritative_position,
		authoritative_rotation_y
	)


	remote_player_movement_state_received.emit(
		state_peer_id,
		authoritative_position,
		authoritative_rotation_y,
		moving,
		sequence
	)


# =========================================================
# DECISIÓN AUTORITATIVA DE MOVIMIENTO
# =========================================================

func _process_movement_decision(
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


	if request_id != latest_move_request_id:
		return


	var accepted := bool(
		data.get(
			"accepted",
			false
		)
	)


	var position_value: Variant = (
		data.get(
			"authoritative_position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		return


	var position_data: Dictionary = (
		position_value
	)


	if (
		not position_data.has("x")
		or
		not position_data.has("y")
		or
		not position_data.has("z")
	):
		return


	var authoritative_position := Vector3(
		float(position_data["x"]),
		float(position_data["y"]),
		float(position_data["z"])
	)


	var authoritative_rotation_y := float(
		data.get(
			"authoritative_rotation_y",
			0.0
		)
	)


	var authorized_target := Vector3.ZERO


	if accepted:
		var target_value: Variant = (
			data.get(
				"authorized_target",
				null
			)
		)


		if typeof(target_value) != TYPE_DICTIONARY:
			return


		var target_data: Dictionary = (
			target_value
		)


		if (
			not target_data.has("x")
			or
			not target_data.has("y")
			or
			not target_data.has("z")
		):
			return


		authorized_target = Vector3(
			float(target_data["x"]),
			float(target_data["y"]),
			float(target_data["z"])
		)


	var reason := String(
		data.get(
			"reason",
			""
		)
	)


	print(
		"GameServerClient | Decisión de movimiento",
		" | Request: ",
		request_id,
		" | Accepted: ",
		accepted,
		" | Target autorizado: ",
		authorized_target
	)


	movement_decision_received.emit(
		request_id,
		accepted,
		authoritative_position,
		authoritative_rotation_y,
		authorized_target,
		reason
	)


# =========================================================
# PLAYER REMOTO ELIMINADO
# =========================================================

func remove_remote_player(
	peer_id: int
) -> void:
	remote_movement_sequences.erase(
		peer_id
	)


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	latest_movement_sequence = 0

	latest_authoritative_position = Vector3.ZERO

	latest_authoritative_rotation_y = 0.0

	latest_authoritative_moving = false

	next_move_request_id = 1

	latest_move_request_id = 0

	remote_movement_sequences.clear()
