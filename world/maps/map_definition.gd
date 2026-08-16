class_name MapDefinition
extends Resource


# =========================================================
# IDENTIDAD
# =========================================================

@export_group("Identity")

@export var map_id: String = ""

@export var display_name: String = ""


# =========================================================
# ESCENA
# =========================================================

@export_group("Scene")

@export var scene: PackedScene = null
