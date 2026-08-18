class_name RemotePlayerActor
extends Node3D


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
