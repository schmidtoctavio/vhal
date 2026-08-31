class_name GameServerVitalsProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal character_vitals_updated(
	character_id: int,
	vitals_snapshot: Dictionary
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_CHARACTER_VITALS_UPDATED: String = (
	"character_vitals_updated"
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

var latest_vitals_snapshot: Dictionary = {}


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


	fail_connection = (
		p_fail_connection
	)


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
		MESSAGE_CHARACTER_VITALS_UPDATED
	):
		return false


	if typeof(data_value) != TYPE_DICTIONARY:
		_fail_connection(
			"El update de Vitals es inválido."
		)


		return true


	_process_character_vitals_updated(
		data_value
	)


	return true


# =========================================================
# CHARACTER VITALS UPDATED
# =========================================================

func _process_character_vitals_updated(
	data: Dictionary
) -> void:
	var character_id := int(
		data.get(
			"character_id",
			0
		)
	)


	if character_id <= 0:
		_fail_connection(
			"Vitals Updated sin Character ID válido."
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
			"Vitals Updated sin snapshot válido."
		)


		return


	var vitals_snapshot: Dictionary = (
		vitals_value
	)


	if (
		not vitals_snapshot.has("hp")
		or
		not vitals_snapshot.has("max_hp")
		or
		not vitals_snapshot.has("mp")
		or
		not vitals_snapshot.has("max_mp")
	):
		_fail_connection(
			"Vitals Updated posee un snapshot incompleto."
		)


		return


	var hp := int(
		vitals_snapshot.get(
			"hp",
			-1
		)
	)

	var max_hp := int(
		vitals_snapshot.get(
			"max_hp",
			0
		)
	)

	var mp := int(
		vitals_snapshot.get(
			"mp",
			-1
		)
	)

	var max_mp := int(
		vitals_snapshot.get(
			"max_mp",
			0
		)
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
			"Vitals Updated contiene valores inválidos."
		)


		return


	# -----------------------------------------------------
	# IDENTIDAD
	#
	# El update debe pertenecer al mismo personaje que
	# originó el World Snapshot autoritativo.
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


		if int(
			character_data.get(
				"id",
				0
			)
		) != character_id:
			_fail_connection(
				"Vitals Updated pertenece a otro personaje."
			)


			return


	latest_vitals_snapshot = (
		vitals_snapshot.duplicate(
			true
		)
	)


	print(
		"GameServerClient | Vitals autoritativos actualizados",
		" | Character ID: ",
		character_id,
		" | HP: ",
		hp,
		"/",
		max_hp,
		" | MP: ",
		mp,
		"/",
		max_mp
	)


	character_vitals_updated.emit(
		character_id,
		latest_vitals_snapshot.duplicate(
			true
		)
	)


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	latest_vitals_snapshot = {}


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
