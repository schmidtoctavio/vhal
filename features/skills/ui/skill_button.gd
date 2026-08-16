class_name SkillButton
extends TextureButton


const SKILL_TOOLTIP_SCENE := preload(
    "res://features/skills/ui/skill_tooltip.tscn"
)


var skill_slot: SkillSlot = null


func setup(
	owner_slot: SkillSlot
) -> void:
	skill_slot = owner_slot

	_refresh_tooltip_text()


func _refresh_tooltip_text() -> void:
	if (
		skill_slot == null
		or
		skill_slot.skill_definition == null
	):
		tooltip_text = ""
		return


	tooltip_text = (
		skill_slot
		.skill_definition
		.display_name
	)


func _make_custom_tooltip(
	_for_text: String
) -> Object:
	if skill_slot == null:
		return null


	var definition := (
		skill_slot.skill_definition
	)


	if definition == null:
		return null


	var tooltip := (
		SKILL_TOOLTIP_SCENE.instantiate()
		as SkillTooltip
	)


	if tooltip == null:
		return null


	tooltip.setup(
		definition.display_name,
		definition.description,
		definition.mana_cost,
		definition.cooldown_duration
	)


	return tooltip

# =========================================================
# DRAG & DROP
# =========================================================

func _can_drop_data(
	_at_position: Vector2,
	data: Variant
) -> bool:
	if skill_slot == null:
		return false


	if typeof(data) != TYPE_DICTIONARY:
		return false


	if data.get(
		"type",
		""
	) != "skill_book_skill":
		return false


	var skill := (
		data.get(
			"skill"
		) as SkillDefinition
	)


	return skill != null


func _drop_data(
	at_position: Vector2,
	data: Variant
) -> void:
	if not _can_drop_data(
		at_position,
		data
	):
		return


	var skill := (
		data.get(
			"skill"
		) as SkillDefinition
	)


	if skill == null:
		return


	skill_slot.request_skill_assignment(
		skill
	)
