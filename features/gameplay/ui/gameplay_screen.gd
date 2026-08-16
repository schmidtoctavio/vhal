class_name GameplayScreen
extends Control



# =========================================================
# PERSONAJE ACTUAL
# =========================================================

var character: CharacterSummary = null


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	selected_character: CharacterSummary
) -> void:
	character = selected_character


	if is_node_ready():
		_refresh_character_debug()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh_character_debug()


# =========================================================
# DEBUG TEMPORAL
# =========================================================

func _refresh_character_debug() -> void:
	if character == null:
		return


	print(
		"GAMEPLAY | Personaje: ",
		character.display_name,
		" | Clase: ",
		character.character_class,
		" | Nivel: ",
		character.level
	)
