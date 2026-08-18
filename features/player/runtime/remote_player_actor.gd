class_name RemotePlayerActor
extends Node3D

# =========================================================
# INTERPOLACIÓN REMOTA
# =========================================================

const POSITION_INTERPOLATION_SPEED: float = 12.0

const ROTATION_INTERPOLATION_SPEED: float = 12.0

# =========================================================
# REFERENCIAS
# =========================================================

@onready var character_visual: CharacterVisual = (
	$CharacterVisual
)

@onready var name_label: Label3D = (
	$NameLabel
)


# =========================================================
# IDENTIDAD
# =========================================================

var peer_id: int = -1

var character_id: int = -1

var character_name: String = ""

var class_id: String = ""

var level: int = 1

var map_id: String = ""

# =========================================================
# ESTADO DE MOVIMIENTO REMOTO
# =========================================================

var last_movement_sequence: int = 0

var target_position: Vector3 = Vector3.ZERO

var target_rotation_y: float = 0.0

var is_moving_remotely: bool = false

# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	presence: Dictionary
) -> bool:
	if presence.is_empty():
		return false


	var new_peer_id := int(
		presence.get(
			"peer_id",
			-1
		)
	)


	if new_peer_id <= 1:
		return false


	var character_value: Variant = (
		presence.get(
			"character",
			null
		)
	)


	if typeof(character_value) != TYPE_DICTIONARY:
		return false


	var character: Dictionary = (
		character_value
	)


	var new_character_id := int(
		character.get(
			"id",
			-1
		)
	)


	var new_character_name := String(
		character.get(
			"name",
			""
		)
	).strip_edges()


	var new_class_id := String(
		character.get(
			"class_id",
			""
		)
	).strip_edges()


	var new_level := int(
		character.get(
			"level",
			1
		)
	)


	if (
		new_character_id <= 0
		or
		new_character_name.is_empty()
		or
		new_class_id.is_empty()
	):
		return false


	var world_value: Variant = (
		presence.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return false


	var world: Dictionary = (
		world_value
	)


	var new_map_id := String(
		world.get(
			"map_id",
			""
		)
	).strip_edges()


	if new_map_id.is_empty():
		return false


	var position_value: Variant = (
		world.get(
			"position",
			null
		)
	)


	if typeof(position_value) != TYPE_VECTOR3:
		return false


	var remote_position: Vector3 = (
		position_value
	)


	var remote_rotation_y := float(
		world.get(
			"rotation_y",
			0.0
		)
	)


	# -----------------------------------------------------
	# IDENTIDAD
	# -----------------------------------------------------

	peer_id = new_peer_id

	character_id = new_character_id

	character_name = new_character_name

	class_id = new_class_id

	level = maxi(
		new_level,
		1
	)

	map_id = new_map_id


	# -----------------------------------------------------
	# TRANSFORM INICIAL AUTORITATIVO
	# -----------------------------------------------------

	global_position = (
		remote_position
	)


	rotation.y = (
		remote_rotation_y
	)

	target_position = (
		remote_position
	)


	target_rotation_y = (
		remote_rotation_y
	)


	is_moving_remotely = false


	last_movement_sequence = 0

	# -----------------------------------------------------
	# VISUAL
	# -----------------------------------------------------

	if character_visual == null:
		return false


	if not character_visual.setup_remote(
		character
	):
		return false


	# -----------------------------------------------------
	# NAMEPLATE
	# -----------------------------------------------------

	if name_label != null:
		name_label.text = (
			character_name
		)


	print(
		"RemotePlayerActor | Preparado",
		" | Peer: ",
		peer_id,
		" | Personaje: ",
		character_name,
		" | Class ID: ",
		class_id,
		" | Nivel: ",
		level,
		" | Posición: ",
		global_position
	)


	return true

# =========================================================
# ESTADO AUTORITATIVO REMOTO
# =========================================================

func apply_authoritative_movement_state(
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	if sequence <= last_movement_sequence:
		return


	last_movement_sequence = sequence


	target_position = (
		authoritative_position
	)


	target_rotation_y = (
		authoritative_rotation_y
	)


	is_moving_remotely = moving


	# -----------------------------------------------------
	# ESTADO FINAL
	# -----------------------------------------------------
	#
	# moving=false es una afirmación exacta del servidor.
	# No dejamos error residual de interpolación.
	# -----------------------------------------------------

	if not moving:
		global_position = (
			authoritative_position
		)


		rotation.y = (
			authoritative_rotation_y
		)


		if character_visual != null:
			character_visual.play_idle()


		print(
			"RemotePlayerActor | Final autoritativo",
			" | Peer: ",
			peer_id,
			" | Seq: ",
			sequence,
			" | Posición: ",
			global_position
		)


		return


	if character_visual != null:
		character_visual.play_run()

# =========================================================
# INTERPOLACIÓN VISUAL
# =========================================================

func _process(
	delta: float
) -> void:
	if not is_moving_remotely:
		return


	if delta <= 0.0:
		return


	var position_weight := clampf(
		POSITION_INTERPOLATION_SPEED
		*
		delta,
		0.0,
		1.0
	)


	var rotation_weight := clampf(
		ROTATION_INTERPOLATION_SPEED
		*
		delta,
		0.0,
		1.0
	)


	global_position = global_position.lerp(
		target_position,
		position_weight
	)


	rotation.y = lerp_angle(
		rotation.y,
		target_rotation_y,
		rotation_weight
	)
