@tool
class_name SkillBookSlot
extends Button


const SKILL_TOOLTIP_SCENE := preload(
    "res://features/skills/ui/skill_tooltip.tscn"
)


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
# VISUAL
# =========================================================

func _refresh() -> void:
	var skill_icon := get_node_or_null(
		"IconMargin/SkillIcon"
	) as TextureRect


	# -----------------------------------------------------
	# SLOT VACÍO
	# -----------------------------------------------------

	if skill_definition == null:
		if skill_icon:
			skill_icon.texture = null
			skill_icon.visible = false


		tooltip_text = ""
		disabled = true

		return


	# -----------------------------------------------------
	# SKILL ASIGNADA
	# -----------------------------------------------------

	disabled = false


	if skill_icon:
		skill_icon.texture = (
			skill_definition.icon
		)

		skill_icon.visible = true


	tooltip_text = (
		skill_definition.display_name
	)


# =========================================================
# TOOLTIP
# =========================================================

func _make_custom_tooltip(
	_for_text: String
) -> Object:
	if skill_definition == null:
		return null


	var tooltip := (
		SKILL_TOOLTIP_SCENE.instantiate()
		as SkillTooltip
	)


	if tooltip == null:
		return null


	tooltip.setup(
		skill_definition.display_name,
		skill_definition.description,
		skill_definition.mana_cost,
		skill_definition.cooldown_duration
	)


	return tooltip

# =========================================================
# DRAG & DROP
# =========================================================

func _get_drag_data(
	_at_position: Vector2
) -> Variant:
	if skill_definition == null:
		return null


	# -----------------------------------------------------
	# DATOS QUE VIAJAN DURANTE EL DRAG
	# -----------------------------------------------------

	var drag_data := {
		"type": "skill_book_skill",
		"skill": skill_definition
	}


	# -----------------------------------------------------
	# PREVIEW VISUAL
	# -----------------------------------------------------

	var preview := TextureRect.new()

	preview.custom_minimum_size = Vector2(
		48,
		48
	)

	preview.texture = (
		skill_definition.icon
	)

	preview.expand_mode = (
		TextureRect.EXPAND_IGNORE_SIZE
	)

	preview.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)

	preview.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


	set_drag_preview(
		preview
	)


	return drag_data
