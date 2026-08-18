class_name NpcActor
extends Node3D


# =========================================================
# DEFINICIÓN
# =========================================================

@export var definition: NpcDefinition = null


# =========================================================
# REFERENCIAS
# =========================================================

@onready var visual_root: Node3D = (
	$VisualRoot
)

@onready var interaction_area: Area3D = (
	$InteractionArea
)

@onready var name_label: Label3D = (
	$NameLabel
)


# =========================================================
# ESTADO
# =========================================================

var initialized: bool = false


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	if definition == null:
		return


	setup(
		definition
	)


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	npc_definition: NpcDefinition
) -> bool:
	if npc_definition == null:
		return false


	var npc_id := (
		npc_definition.npc_id.strip_edges()
	)


	var display_name := (
		npc_definition.display_name.strip_edges()
	)


	var service_id := (
		npc_definition.service_id.strip_edges()
	)


	if npc_id.is_empty():
		return false


	if display_name.is_empty():
		return false


	if service_id.is_empty():
		return false


	definition = npc_definition


	if name_label != null:
		name_label.text = (
			display_name
		)


	initialized = true


	print(
		"NpcActor | Preparado",
		" | NPC: ",
		npc_id,
		" | Nombre: ",
		display_name,
		" | Servicio: ",
		service_id,
		" | Rango: ",
		npc_definition.interaction_range
	)


	return true


# =========================================================
# IDENTIDAD
# =========================================================

func get_npc_id() -> String:
	if definition == null:
		return ""


	return (
		definition.npc_id.strip_edges()
	)


func get_display_name() -> String:
	if definition == null:
		return ""


	return (
		definition.display_name.strip_edges()
	)


func get_service_id() -> String:
	if definition == null:
		return ""


	return (
		definition.service_id.strip_edges()
	)


func get_interaction_range() -> float:
	if definition == null:
		return 0.0


	return maxf(
		definition.interaction_range,
		0.0
	)
