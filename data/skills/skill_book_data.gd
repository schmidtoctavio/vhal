class_name SkillBookData
extends RefCounted


# =========================================================
# SEÑALES
# =========================================================

signal skill_learned(
	skill: SkillDefinition
)

signal skill_removed(
	skill: SkillDefinition
)

signal changed


# =========================================================
# ESTADO
# =========================================================

var _skills: Array[SkillDefinition] = []


# =========================================================
# CONSULTAR
# =========================================================

func get_skills() -> Array[SkillDefinition]:
	return _skills.duplicate()


func get_skill_count() -> int:
	return _skills.size()


func has_skill(
	skill: SkillDefinition
) -> bool:
	if skill == null:
		return false

	return _skills.has(
		skill
	)


func has_skill_id(
	skill_id: StringName
) -> bool:
	for skill in _skills:
		if skill == null:
			continue

		if skill.skill_id == skill_id:
			return true

	return false


# =========================================================
# APRENDER
# =========================================================

func learn_skill(
	skill: SkillDefinition
) -> bool:
	if skill == null:
		return false


	if has_skill_id(
		skill.skill_id
	):
		return false


	_skills.append(
		skill
	)


	skill_learned.emit(
		skill
	)

	changed.emit()

	return true


# =========================================================
# QUITAR
# =========================================================

func remove_skill(
	skill: SkillDefinition
) -> bool:
	if skill == null:
		return false


	var index := (
		_skills.find(
			skill
		)
	)


	if index < 0:
		return false


	var removed_skill := (
		_skills[index]
	)


	_skills.remove_at(
		index
	)


	skill_removed.emit(
		removed_skill
	)

	changed.emit()

	return true
