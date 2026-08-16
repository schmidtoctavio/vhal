class_name PlayerRuntimeState
extends RefCounted


# =========================================================
# IDENTIDAD
# =========================================================

var character_summary: CharacterSummary = null

# =========================================================
# MUNDO
# =========================================================

var world: PlayerWorldState = null

# =========================================================
# VITALES
# =========================================================

var vitals: VitalsState = null

# =========================================================
# EXPERIENCIA
# =========================================================

var experience: ExperienceState = null

# =========================================================
# INVENTARIO
# =========================================================

var inventory: InventoryData = null


# =========================================================
# EQUIPAMIENTO
# =========================================================

var equipment: EquipmentData = null


# =========================================================
# SKILLS
# =========================================================

var skill_book: SkillBookData = null

var skill_hotbar: SkillHotbarData = null


# =========================================================
# MONEDA
# =========================================================

var currency: CurrencyState = null


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init(
	summary: CharacterSummary = null
) -> void:
	character_summary = summary


	world = PlayerWorldState.new()


	vitals = VitalsState.new()


	experience = ExperienceState.new()


	inventory = InventoryData.new()


	equipment = EquipmentData.new()


	skill_book = SkillBookData.new()


	skill_hotbar = SkillHotbarData.new()


	currency = CurrencyState.new()
