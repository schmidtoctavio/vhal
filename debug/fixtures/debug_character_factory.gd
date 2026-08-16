class_name DebugCharacterFactory
extends RefCounted


# =========================================================
# CONFIGURACIÓN DEBUG
# =========================================================

const CHARACTER_SLOT_COUNT: int = 5

const FIRST_DYNAMIC_CHARACTER_ID: int = 100


# =========================================================
# ROSTER DEFAULT
# =========================================================

static func create_default_roster() -> Array[CharacterSummary]:
	var characters: Array[CharacterSummary] = []


	characters.resize(
		CHARACTER_SLOT_COUNT
	)


	characters[0] = CharacterSummary.new(
		1,
		"Atilio",
		"Dark Knight",
		120,
		0
	)


	characters[1] = CharacterSummary.new(
		2,
		"Lyra",
		"Elf",
		85,
		1
	)


	characters[2] = CharacterSummary.new(
		3,
		"Merlin",
		"Dark Wizard",
		57,
		2
	)


	return characters
