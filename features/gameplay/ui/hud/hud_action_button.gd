@tool
class_name HudActionButton
extends Button


# =========================================================
# CONFIGURACIÓN
# =========================================================

@export_group("Action")

@export var action_id: StringName = &"action"


@export_group("Visual")

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_refresh()


@export var hotkey_text: String = "":
	set(value):
		hotkey_text = value
		_refresh()


@export var action_tooltip: String = "":
	set(value):
		action_tooltip = value
		_refresh()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh()


# =========================================================
# VISUAL
# =========================================================

func _refresh() -> void:
	var icon_rect := get_node_or_null(
		"IconMargin/Icon"
	) as TextureRect


	var hotkey_label := get_node_or_null(
		"HotkeyLabel"
	) as Label


	if icon_rect:
		icon_rect.texture = icon_texture


	if hotkey_label:
		hotkey_label.text = hotkey_text
		hotkey_label.visible = (
			not hotkey_text.is_empty()
		)


	tooltip_text = action_tooltip
