class_name NpcDefinition
extends Resource


# =========================================================
# IDENTIDAD
# =========================================================

@export_group("Identity")

@export var npc_id: String = ""

@export var display_name: String = ""


# =========================================================
# INTERACCIÓN
# =========================================================

@export_group("Interaction")

@export var service_id: String = ""

@export_range(0.5, 10.0, 0.1)
var interaction_range: float = 2.5
