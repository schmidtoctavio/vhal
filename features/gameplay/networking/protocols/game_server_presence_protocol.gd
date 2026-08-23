class_name GameServerPresenceProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal world_presence_snapshot_received(
	players: Array
)

signal remote_player_joined(
	player: Dictionary
)

signal remote_player_left(
	peer_id: int
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_WORLD_PRESENCE_SNAPSHOT: String = (
	"world_presence_snapshot"
)

const MESSAGE_PLAYER_PRESENCE_JOINED: String = (
	"player_presence_joined"
)

const MESSAGE_PLAYER_PRESENCE_LEFT: String = (
	"player_presence_left"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var get_local_peer_id: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var remote_players: Dictionary = {}


# =========================================================
# SETUP
# =========================================================

func setup(
	p_get_local_peer_id: Callable
) -> bool:
	if not p_get_local_peer_id.is_valid():
		return false


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
		MESSAGE_WORLD_PRESENCE_SNAPSHOT:
			if typeof(data_value) == TYPE_DICTIONARY:
				var presence_data: Dictionary = (
					data_value
				)


				_process_world_presence_snapshot(
					presence_data
				)


			return true

		MESSAGE_PLAYER_PRESENCE_JOINED:
			if typeof(data_value) == TYPE_DICTIONARY:
				var joined_data: Dictionary = (
					data_value
				)


				_process_player_presence_joined(
					joined_data
				)


			return true

		MESSAGE_PLAYER_PRESENCE_LEFT:
			if typeof(data_value) == TYPE_DICTIONARY:
				var left_data: Dictionary = (
					data_value
				)


				_process_player_presence_left(
					left_data
				)


			return true


	return false


# =========================================================
# VALIDAR PRESENCIA REMOTA
# =========================================================

func _parse_remote_player_presence(
	value: Variant
) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}


	var data: Dictionary = (
		value
	)


	var peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if peer_id <= 1:
		return {}


	if peer_id == int(
		get_local_peer_id.call()
	):
		return {}


	var character_value: Variant = (
		data.get(
			"character",
			null
		)
	)


	if typeof(character_value) != TYPE_DICTIONARY:
		return {}


	var character: Dictionary = (
		character_value
	)


	var character_id := int(
		character.get(
			"id",
			-1
		)
	)


	var character_name := String(
		character.get(
			"name",
			""
		)
	).strip_edges()


	var class_id := String(
		character.get(
			"class_id",
			""
		)
	).strip_edges()


	if (
		character_id <= 0
		or
		character_name.is_empty()
		or
		class_id.is_empty()
	):
		return {}


	var world_value: Variant = (
		data.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return {}


	var world: Dictionary = (
		world_value
	)


	var map_id := String(
		world.get(
			"map_id",
			""
		)
	).strip_edges()


	if map_id.is_empty():
		return {}


	var position_value: Variant = (
		world.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		return {}


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
		return {}


	var position := Vector3(
		float(position_data["x"]),
		float(position_data["y"]),
		float(position_data["z"])
	)


	var rotation_y := float(
		world.get(
			"rotation_y",
			0.0
		)
	)


	return {
		"peer_id": peer_id,

		"character": {
			"id": character_id,
			"name": character_name,
			"class_id": class_id,
			"level": int(
				character.get(
					"level",
					1
				)
			),
		},

		"world": {
			"map_id": map_id,
			"position": position,
			"rotation_y": rotation_y,
		},
	}


# =========================================================
# ROSTER INICIAL DEL MUNDO
# =========================================================

func _process_world_presence_snapshot(
	data: Dictionary
) -> void:
	var players_value: Variant = (
		data.get(
			"players",
			null
		)
	)


	if typeof(players_value) != TYPE_ARRAY:
		return


	var players: Array = (
		players_value
	)


	remote_players.clear()


	for player_value: Variant in players:
		var player := (
			_parse_remote_player_presence(
				player_value
			)
		)


		if player.is_empty():
			continue


		var peer_id := int(
			player.get(
				"peer_id",
				-1
			)
		)


		remote_players[
			peer_id
		] = player


	print(
		"GameServerClient | Roster de mundo recibido",
		" | Remotos: ",
		remote_players.size()
	)


	world_presence_snapshot_received.emit(
		remote_players.values()
	)


# =========================================================
# PLAYER REMOTO ENTRÓ
# =========================================================

func _process_player_presence_joined(
	data: Dictionary
) -> void:
	var player_value: Variant = (
		data.get(
			"player",
			null
		)
	)


	var player := (
		_parse_remote_player_presence(
			player_value
		)
	)


	if player.is_empty():
		return


	var peer_id := int(
		player.get(
			"peer_id",
			-1
		)
	)


	remote_players[
		peer_id
	] = player


	var character: Dictionary = (
		player.get(
			"character",
			{}
		)
	)


	print(
		"GameServerClient | Player remoto entró",
		" | Peer: ",
		peer_id,
		" | Personaje: ",
		character.get(
			"name",
			"?"
		)
	)


	remote_player_joined.emit(
		player.duplicate(
			true
		)
	)


# =========================================================
# PLAYER REMOTO SALIÓ
# =========================================================

func _process_player_presence_left(
	data: Dictionary
) -> void:
	var peer_id := int(
		data.get(
			"peer_id",
			-1
		)
	)


	if peer_id <= 1:
		return


	if peer_id == int(
		get_local_peer_id.call()
	):
		return


	if not remote_players.has(
		peer_id
	):
		return


	remote_players.erase(
		peer_id
	)


	print(
		"GameServerClient | Player remoto salió",
		" | Peer: ",
		peer_id
	)


	remote_player_left.emit(
		peer_id
	)


# =========================================================
# CONSULTAS PARA MOVEMENT
# =========================================================

func has_remote_player(
	peer_id: int
) -> bool:
	return remote_players.has(
		peer_id
	)


func update_remote_world_state(
	peer_id: int,
	position: Vector3,
	rotation_y: float
) -> void:
	if not remote_players.has(
		peer_id
	):
		return


	var remote_player_value: Variant = (
		remote_players[
			peer_id
		]
	)


	if typeof(remote_player_value) != TYPE_DICTIONARY:
		return


	var remote_player: Dictionary = (
		remote_player_value
	)


	var world_value: Variant = (
		remote_player.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return


	var world: Dictionary = (
		world_value
	)


	world[
		"position"
	] = position


	world[
		"rotation_y"
	] = rotation_y


	remote_player[
		"world"
	] = world


	remote_players[
		peer_id
	] = remote_player


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	remote_players.clear()
