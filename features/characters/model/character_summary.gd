class_name CharacterSummary
extends RefCounted


# =========================================================
# DATOS
# =========================================================

var character_id: int = 0

var display_name: String = ""

var character_class: String = ""

var character_class_id: String = ""

var level: int = 1

var slot_index: int = 0


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	p_character_id: int = 0,
	p_display_name: String = "",
	p_character_class: String = "",
	p_level: int = 1,
	p_slot_index: int = 0,
	p_character_class_id: String = ""
) -> void:
	character_id = p_character_id

	display_name = p_display_name

	character_class = p_character_class

	character_class_id = p_character_class_id

	level = p_level

	slot_index = p_slot_index
