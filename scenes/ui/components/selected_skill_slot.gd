@tool
class_name SelectedSkillSlot
extends Button


# =========================================================
# SEÑALES
# =========================================================

signal skills_panel_requested


# =========================================================
# SKILL
# =========================================================

@export_group("Skill")

@export var skill_definition: SkillDefinition:
	set(value):
		skill_definition = value

		_refresh()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh()


	if Engine.is_editor_hint():
		return


	if not pressed.is_connected(
		_on_pressed
	):
		pressed.connect(
			_on_pressed
		)


# =========================================================
# CONFIGURAR SKILL
# =========================================================

func set_skill(
	definition: SkillDefinition
) -> void:
	skill_definition = definition


func clear_skill() -> void:
	skill_definition = null


func has_skill() -> bool:
	return (
		skill_definition != null
	)


# =========================================================
# CLICK
# =========================================================

func _on_pressed() -> void:
	skills_panel_requested.emit()


# =========================================================
# VISUAL
# =========================================================

func _refresh() -> void:
	var icon_rect := get_node_or_null(
		"IconMargin/SkillIcon"
	) as TextureRect


	# -----------------------------------------------------
	# SLOT VACÍO
	# -----------------------------------------------------

	if skill_definition == null:
		if icon_rect:
			icon_rect.texture = null
			icon_rect.visible = false


		tooltip_text = "Habilidades"

		return


	# -----------------------------------------------------
	# SKILL SELECCIONADA
	# -----------------------------------------------------

	if icon_rect:
		icon_rect.texture = (
			skill_definition.icon
		)

		icon_rect.visible = true


	tooltip_text = (
		skill_definition.display_name
	)
