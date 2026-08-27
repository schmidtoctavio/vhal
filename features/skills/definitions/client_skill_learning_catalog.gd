class_name ClientSkillLearningCatalog
extends RefCounted


# =========================================================
# MAPPING DE PRESENTACIÓN / INTENCIÓN
#
# NO es autoridad de gameplay.
#
# Sólo permite que el cliente sepa qué intención enviar
# al activar visualmente un Skill Scroll.
#
# Game Server vuelve a validar:
# - Skill
# - clase
# - nivel
# - Trainer
# - Scroll UID
# - ownership
# =========================================================

const SKILL_BY_SCROLL_ITEM_ID: Dictionary = {
	"skill_scroll_fire_ball": "fire_ball",
	"skill_scroll_poison": "poison",
	"skill_scroll_heal": "heal",
}


static func get_skill_id_for_scroll(
	item_id: String
) -> String:
	var normalized_item_id := (
		item_id
		.strip_edges()
		.to_lower()
	)


	if not SKILL_BY_SCROLL_ITEM_ID.has(
		normalized_item_id
	):
		return ""


	return String(
		SKILL_BY_SCROLL_ITEM_ID[
			normalized_item_id
		]
	)


static func is_skill_scroll(
	item_id: String
) -> bool:
	return not get_skill_id_for_scroll(
		item_id
	).is_empty()
