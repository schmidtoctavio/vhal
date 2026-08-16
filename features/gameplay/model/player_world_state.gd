class_name PlayerWorldState
extends RefCounted


# =========================================================
# IDENTIDAD DEL MAPA
# =========================================================

var map_id: String = ""


# =========================================================
# TRANSFORM
# =========================================================

var position: Vector3 = Vector3.ZERO

var rotation_y: float = 0.0


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	p_map_id: String,
	p_position: Vector3 = Vector3.ZERO,
	p_rotation_y: float = 0.0
) -> void:
	map_id = p_map_id.strip_edges()

	position = p_position

	rotation_y = p_rotation_y
