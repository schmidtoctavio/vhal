class_name GameServerWorldProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal world_snapshot_received(
	snapshot: Dictionary
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_WORLD_SNAPSHOT: String = (
	"world_snapshot"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var get_local_peer_id: Callable = Callable()

var fail_connection: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var latest_world_snapshot: Dictionary = {}


# =========================================================
# SETUP
# =========================================================

func setup(
	p_get_local_peer_id: Callable,
	p_fail_connection: Callable
) -> bool:
	if not p_get_local_peer_id.is_valid():
		return false


	if not p_fail_connection.is_valid():
		return false


	get_local_peer_id = p_get_local_peer_id

	fail_connection = p_fail_connection


	return true


# =========================================================
# PROCESAR MENSAJE
# =========================================================

func process_message(
	message_type: String,
	data_value: Variant
) -> bool:
	if message_type != MESSAGE_WORLD_SNAPSHOT:
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot de mundo es inválido."
		)


		return true


	var snapshot: Dictionary = (
		data_value
	)


	_process_world_snapshot(
		snapshot
	)


	return true


# =========================================================
# SNAPSHOT DE MUNDO
# =========================================================

func _process_world_snapshot(
	snapshot: Dictionary
) -> void:
	var snapshot_peer_id := int(
		snapshot.get(
			"peer_id",
			-1
		)
	)


	var local_peer_id := int(
		get_local_peer_id.call()
	)


	if snapshot_peer_id != local_peer_id:
		_fail_connection(
			"El snapshot pertenece a otro peer."
		)


		return


	var account_id := int(
		snapshot.get(
			"account_id",
			-1
		)
	)


	if account_id <= 0:
		_fail_connection(
			"El snapshot no posee una cuenta válida."
		)


		return


	var character_value: Variant = (
		snapshot.get(
			"character",
			null
		)
	)


	if typeof(character_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee un personaje válido."
		)


		return


	var character_data: Dictionary = (
		character_value
	)


	var character_id := int(
		character_data.get(
			"id",
			-1
		)
	)


	if character_id <= 0:
		_fail_connection(
			"El snapshot posee un Character ID inválido."
		)


		return

	# =====================================================
	# PROGRESIÓN AUTORITATIVA
	# =====================================================

	var progression_value: Variant = (
		snapshot.get(
			"progression",
			null
		)
	)


	if typeof(progression_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee Progression válida."
		)


		return


	var progression_data: Dictionary = (
		progression_value
	)

	# =====================================================
	# PRIMARY STATS AUTORITATIVOS
	# =====================================================

	var primary_stats_value: Variant = (
		snapshot.get(
			"primary_stats",
			null
		)
	)


	if typeof(primary_stats_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee Primary Stats válidos."
		)


		return


	var primary_stats_candidate := (
		PrimaryStatsState.new()
	)


	if not primary_stats_candidate.apply_snapshot(
		primary_stats_value
	):
		_fail_connection(
			"Los Primary Stats del snapshot son inválidos."
		)


		return

	# =====================================================
	# SKILLS AUTORITATIVAS
	# =====================================================

	var skills_value: Variant = (
		snapshot.get(
			"skills",
			null
		)
	)


	if typeof(skills_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee Skills válidas."
		)

		return


	var skills_data: Dictionary = (
		skills_value
	)


	var learned_skill_ids_value: Variant = (
		skills_data.get(
			"learned_skill_ids",
			null
		)
	)


	if typeof(learned_skill_ids_value) != TYPE_ARRAY:
		_fail_connection(
			"El snapshot no posee learned_skill_ids válidas."
		)

		return


	var learned_skill_ids: Array[String] = []

	var learned_skill_ids_seen: Dictionary = {}


	for skill_id_value: Variant in (
		learned_skill_ids_value
		as Array
	):
		var skill_id := String(
			skill_id_value
		).strip_edges().to_lower()


		if skill_id.is_empty():
			_fail_connection(
				"El snapshot posee un Skill ID vacío."
			)

			return


		if learned_skill_ids_seen.has(
			skill_id
		):
			_fail_connection(
				"El snapshot posee Skills duplicadas."
			)

			return


		learned_skill_ids_seen[
			skill_id
		] = true


		learned_skill_ids.append(
			skill_id
		)

	var level := int(
		progression_data.get(
			"level",
			0
		)
	)

	if primary_stats_candidate.level != level:
		_fail_connection(
			"Level inconsistente en Primary Stats."
		)


		return

	var experience := int(
		progression_data.get(
			"experience",
			-1
		)
	)


	var experience_required := int(
		progression_data.get(
			"experience_required",
			0
		)
	)


	if (
		level <= 0
		or
		experience < 0
		or
		experience_required <= 0
		or
		experience >= experience_required
	):
		_fail_connection(
			"La Progression del snapshot es inválida."
		)


		return


	var character_level := int(
		character_data.get(
			"level",
			0
		)
	)


	if character_level != level:
		_fail_connection(
			"Level inconsistente en el snapshot."
		)


		return

	# =========================================================
	# VITALES AUTORITATIVOS
	# =========================================================

	var vitals_value: Variant = (
		snapshot.get(
			"vitals",
			null
		)
	)


	if typeof(vitals_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee vitals válidos."
		)


		return


	var vitals_data: Dictionary = (
		vitals_value
	)


	if (
		not vitals_data.has("hp")
		or
		not vitals_data.has("max_hp")
		or
		not vitals_data.has("mp")
		or
		not vitals_data.has("max_mp")
	):
		_fail_connection(
			"Los vitals del snapshot están incompletos."
		)


		return


	var hp := int(
		vitals_data["hp"]
	)


	var max_hp := int(
		vitals_data["max_hp"]
	)


	var mp := int(
		vitals_data["mp"]
	)


	var max_mp := int(
		vitals_data["max_mp"]
	)


	if (
		max_hp <= 0
		or
		hp < 0
		or
		hp > max_hp
		or
		max_mp <= 0
		or
		mp < 0
		or
		mp > max_mp
	):
		_fail_connection(
			"Los vitals del snapshot son inválidos."
		)


		return


	var world_value: Variant = (
		snapshot.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee datos de mundo."
		)


		return


	var world_data: Dictionary = (
		world_value
	)


	var map_id := String(
		world_data.get(
			"map_id",
			""
		)
	).strip_edges()


	if map_id.is_empty():
		_fail_connection(
			"El snapshot no posee un mapa válido."
		)


		return


	var position_value: Variant = (
		world_data.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El snapshot no posee una posición válida."
		)


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
		_fail_connection(
			"La posición del snapshot está incompleta."
		)


		return


	var position := Vector3(
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


	var rotation_y := float(
		world_data.get(
			"rotation_y",
			0.0
		)
	)


	latest_world_snapshot = {
		"peer_id": snapshot_peer_id,

		"account_id": account_id,

		"character": character_data.duplicate(
			true
		),

		"progression": {
			"level": level,

			"experience": experience,

			"experience_required": (
				experience_required
			),
		},

		"primary_stats": (
			primary_stats_candidate.to_snapshot()
		),

		"skills": {
			"learned_skill_ids": (
				learned_skill_ids.duplicate()
			),
		},

		"vitals": {
			"hp": hp,
			"max_hp": max_hp,

			"mp": mp,
			"max_mp": max_mp,
		},

		"world": {
			"map_id": map_id,

			"position": {
				"x": position.x,
				"y": position.y,
				"z": position.z,
			},

			"rotation_y": rotation_y,
		},
	}


	print(
		"GameServerClient | Snapshot autoritativo recibido",
		" | Character ID: ",
		character_id,
		" | Mapa: ",
		map_id,
		" | Posición: ",
		position,
		" | HP: ",
		hp,
		"/",
		max_hp,
		" | MP: ",
		mp,
		"/",
		max_mp,
		" | Level: ",
		level,
		" | EXP: ",
		experience,
		"/",
		experience_required,
		" | Skills: ",
		learned_skill_ids,
		" | Stats revision: ",
		primary_stats_candidate.revision,
		" | Unspent: ",
		primary_stats_candidate.unspent_points,
	)


	world_snapshot_received.emit(
		latest_world_snapshot.duplicate(
			true
		)
	)


# =========================================================
# CONSULTAR SNAPSHOT
# =========================================================

func get_latest_world_snapshot() -> Dictionary:
	return latest_world_snapshot.duplicate(
		true
	)


# =========================================================
# ERROR DE CONEXIÓN
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
	latest_world_snapshot = {}
