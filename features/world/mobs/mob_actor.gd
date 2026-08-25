class_name MobActor
extends Node3D


# =========================================================
# IDENTIDAD
# =========================================================

var entity_id: String = ""

var mob_type_id: String = ""

var display_name: String = ""

var level: int = 1


# =========================================================
# ESTADO AUTORITATIVO REPRESENTADO
# =========================================================

var alive: bool = true

var hp: int = 1

var max_hp: int = 1


# =========================================================
# REFERENCIAS
# =========================================================

@onready var visual_root: Node3D = (
	$VisualRoot
)

@onready var name_label: Label3D = (
	$NameLabel
)

@onready var vitals_label: Label3D = (
	$VitalsLabel
)

@onready var target_area: Area3D = (
	$TargetArea
)

@onready var target_collision_shape: CollisionShape3D = (
	$TargetArea/CollisionShape3D
)

# =========================================================
# CONFIGURAR
# =========================================================

func setup(
	snapshot: Dictionary
) -> bool:
	if snapshot.is_empty():
		return false


	var new_entity_id := String(
		snapshot.get(
			"entity_id",
			""
		)
	).strip_edges().to_lower()


	var new_mob_type_id := String(
		snapshot.get(
			"mob_type_id",
			""
		)
	).strip_edges().to_lower()


	var new_display_name := String(
		snapshot.get(
			"display_name",
			""
		)
	).strip_edges()


	var new_level := int(
		snapshot.get(
			"level",
			0
		)
	)


	if (
		new_entity_id.is_empty()
		or
		new_mob_type_id.is_empty()
		or
		new_display_name.is_empty()
		or
		new_level <= 0
	):
		return false


	var vitals_value: Variant = (
		snapshot.get(
			"vitals",
			null
		)
	)


	if typeof(vitals_value) != TYPE_DICTIONARY:
		return false


	var vitals: Dictionary = (
		vitals_value
	)


	var new_hp := int(
		vitals.get(
			"hp",
			-1
		)
	)

	var new_max_hp := int(
		vitals.get(
			"max_hp",
			0
		)
	)


	if (
		new_max_hp <= 0
		or
		new_hp < 0
		or
		new_hp > new_max_hp
	):
		return false

	var new_alive := bool(
		snapshot.get(
			"alive",
			false
		)
	)


	if new_alive != (new_hp > 0):
		return false

	var world_value: Variant = (
		snapshot.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return false


	var world: Dictionary = (
		world_value
	)


	var world_position_value: Variant = (
		world.get(
			"position",
			null
		)
	)


	if typeof(world_position_value) != TYPE_VECTOR3:
		return false


	var world_position: Vector3 = (
		world_position_value
	)


	var world_rotation_y := float(
		world.get(
			"rotation_y",
			0.0
		)
	)


	entity_id = new_entity_id

	mob_type_id = new_mob_type_id

	display_name = new_display_name

	level = new_level

	alive = new_alive

	hp = new_hp

	max_hp = new_max_hp

	position = world_position

	rotation.y = world_rotation_y

	name = (
		"Mob_%s"
		%
		entity_id
	)


	_refresh_labels()
	_refresh_lifecycle_state()

	print(
		"MobActor | Preparado",
		" | Entity: ",
		entity_id,
		" | Type: ",
		mob_type_id,
		" | Nombre: ",
		display_name,
		" | Nivel: ",
		level,
		" | HP: ",
		hp,
		"/",
		max_hp,
		" | Posición: ",
		position
	)


	return true


# =========================================================
# LABELS
# =========================================================

func _refresh_labels() -> void:
	if name_label != null:
		if alive:
			name_label.text = (
				"%s [Lv. %d]"
				%
				[
					display_name,
					level,
				]
			)

		else:
			name_label.text = (
				"%s [Lv. %d] [DEAD]"
				%
				[
					display_name,
					level,
				]
			)


	if vitals_label != null:
		vitals_label.text = (
			"%d / %d HP"
			%
			[
				hp,
				max_hp,
			]
		)

# =========================================================
# LIFECYCLE VISUAL
# =========================================================

func _refresh_lifecycle_state() -> void:
	var targetable := (
		is_targetable()
	)


	# -----------------------------------------------------
	# REPRESENTACIÓN TEMPORAL DE MUERTE
	#
	# Todavía no tenemos animación real.
	# Acostamos el placeholder para hacer visible el estado.
	# -----------------------------------------------------

	if visual_root != null:
		if alive:
			visual_root.rotation.z = 0.0

		else:
			visual_root.rotation.z = (
				deg_to_rad(
					90.0
				)
			)


	# -----------------------------------------------------
	# PICKING
	# -----------------------------------------------------

	if target_collision_shape != null:
		target_collision_shape.set_deferred(
			"disabled",
			not targetable
		)


	if target_area != null:
		target_area.set_deferred(
			"monitoring",
			targetable
		)


		target_area.set_deferred(
			"monitorable",
			targetable
		)

# =========================================================
# TARGETING
# =========================================================

func get_entity_id() -> String:
	return (
		entity_id
		.strip_edges()
		.to_lower()
	)


func is_targetable() -> bool:
	return (
		alive
		and
		hp > 0
		and
		not get_entity_id().is_empty()
	)
