class_name GameServerProgressionProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal character_progression_updated(
	snapshot: Dictionary
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_CHARACTER_PROGRESSION_UPDATED: String = (
	"character_progression_updated"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var get_latest_world_snapshot: Callable = (
	Callable()
)

var fail_connection: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var latest_progression_snapshot: Dictionary = {}


# =========================================================
# SETUP
# =========================================================

func setup(
	p_get_latest_world_snapshot: Callable,
	p_fail_connection: Callable
) -> bool:
	if not p_get_latest_world_snapshot.is_valid():
		return false


	if not p_fail_connection.is_valid():
		return false


	get_latest_world_snapshot = (
		p_get_latest_world_snapshot
	)


	fail_connection = p_fail_connection


	return true


# =========================================================
# PROCESAR
# =========================================================

func process_message(
	message_type: String,
	data_value: Variant
) -> bool:
	if (
		message_type
		!=
		MESSAGE_CHARACTER_PROGRESSION_UPDATED
	):
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El estado de Progression es inválido."
		)


		return true


	_process_progression_updated(
		data_value
	)


	return true


# =========================================================
# PROGRESSION UPDATED
# =========================================================

func _process_progression_updated(
	data: Dictionary
) -> void:
	var character_id := int(
		data.get(
			"character_id",
			0
		)
	)


	var level := int(
		data.get(
			"level",
			0
		)
	)


	var experience := int(
		data.get(
			"experience",
			-1
		)
	)


	var experience_required := int(
		data.get(
			"experience_required",
			0
		)
	)


	var experience_gained := int(
		data.get(
			"experience_gained",
			0
		)
	)


	var levels_gained := int(
		data.get(
			"levels_gained",
			-1
		)
	)


	if (
		character_id <= 0
		or
		level <= 0
		or
		experience < 0
		or
		experience_required <= 0
		or
		experience >= experience_required
		or
		experience_gained <= 0
		or
		levels_gained < 0
	):
		_fail_connection(
			"El Game Server envió Progression inválida."
		)


		return


	# -----------------------------------------------------
	# IDENTIDAD
	# -----------------------------------------------------

	var world_snapshot: Dictionary = (
		get_latest_world_snapshot.call()
	)


	if not world_snapshot.is_empty():
		var character_value: Variant = (
			world_snapshot.get(
				"character",
				null
			)
		)


		if typeof(character_value) != TYPE_DICTIONARY:
			_fail_connection(
				"El snapshot local de personaje es inválido."
			)


			return


		var character_data: Dictionary = (
			character_value
		)


		if (
			int(
				character_data.get(
					"id",
					0
				)
			)
			!=
			character_id
		):
			_fail_connection(
				"Progression pertenece a otro personaje."
			)


			return


	latest_progression_snapshot = {
		"character_id": character_id,

		"level": level,

		"experience": experience,

		"experience_required": (
			experience_required
		),

		"experience_gained": (
			experience_gained
		),

		"levels_gained": levels_gained,
	}


	print(
		"GameServerClient | Progression autoritativa recibida",
		" | Character ID: ",
		character_id,
		" | Level: ",
		level,
		" | EXP: ",
		experience,
		"/",
		experience_required,
		" | Gained: +",
		experience_gained,
		" | Levels gained: ",
		levels_gained
	)


	character_progression_updated.emit(
		latest_progression_snapshot.duplicate(
			true
		)
	)


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	latest_progression_snapshot = {}


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
