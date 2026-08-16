class_name LoadingScreen
extends Control


# =========================================================
# REFERENCIAS
# =========================================================

@onready var character_label: Label = (
	$CenterContainer/Content/CharacterLabel
)


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	character_name: String
) -> void:
	var normalized_name := (
		character_name.strip_edges()
	)


	if normalized_name.is_empty():
		character_label.text = (
			"Preparando personaje..."
		)

		return


	character_label.text = (
		"Preparando a %s..."
		% normalized_name
	)
