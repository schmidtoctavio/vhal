class_name ClientSkillCatalog
extends RefCounted


const FIRE_BALL := preload(
	"res://features/skills/definitions/catalog/fire_ball.tres"
)

const POISON := preload(
	"res://features/skills/definitions/catalog/poison.tres"
)

const HEAL := preload(
	"res://features/skills/definitions/catalog/heal.tres"
)


const DEFAULT_HOTBAR_ORDER: Array[String] = [
	"fire_ball",
	"poison",
	"heal",
]


static func get_definition(
	skill_id: String
) -> SkillDefinition:
	var normalized_skill_id := (
		skill_id
		.strip_edges()
		.to_lower()
	)


	match normalized_skill_id:
		"fire_ball":
			return FIRE_BALL as SkillDefinition

		"poison":
			return POISON as SkillDefinition

		"heal":
			return HEAL as SkillDefinition


	return null
