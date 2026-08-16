class_name ScreenRouter
extends Node


# =========================================================
# REFERENCIAS
# =========================================================

var screen_root: Control = null


# =========================================================
# PANTALLA ACTUAL
# =========================================================

var current_screen: Control = null


# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	root: Control
) -> void:
	screen_root = root


# =========================================================
# CAMBIO DE PANTALLA
# =========================================================

func change_screen(
	screen_scene: PackedScene
) -> Control:
	if screen_root == null:
		push_error(
			"ScreenRouter no tiene ScreenRoot configurado."
		)

		return null


	if current_screen != null:
		if is_instance_valid(
			current_screen
		):
			current_screen.queue_free()


	var new_screen := (
		screen_scene.instantiate()
		as Control
	)


	if new_screen == null:
		push_error(
			"No se pudo instanciar la pantalla."
		)

		return null


	screen_root.add_child(
		new_screen
	)


	new_screen.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


	current_screen = new_screen


	return new_screen
