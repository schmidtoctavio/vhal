class_name DebugPlayerStateFactory
extends RefCounted


# =========================================================
# VALORES DEFAULT DE DEBUG
# =========================================================

const DEFAULT_MAX_HP: int = 100000
const DEFAULT_MAX_MP: int = 350

const DEFAULT_EXPERIENCE: int = 42000
const DEFAULT_EXPERIENCE_REQUIRED: int = 100000

const DEFAULT_ZEN: int = 125000

# =========================================================
# DEFINICIONES DE ITEMS
# =========================================================

const BRONZE_SWORD := preload(
	"res://features/items/definitions/catalog/bronze_sword.tres"
)

const HEALTH_POTION := preload(
	"res://features/items/definitions/catalog/health_potion.tres"
)


# =========================================================
# DEFINICIONES DE SKILLS
# =========================================================

const FIRE_BALL := preload(
	"res://features/skills/definitions/catalog/fire_ball.tres"
)

const POISON := preload(
	"res://features/skills/definitions/catalog/poison.tres"
)

const HEAL := preload(
	"res://features/skills/definitions/catalog/heal.tres"
)


# =========================================================
# CREAR ESTADO DEFAULT
# =========================================================

static func create_default() -> PlayerRuntimeState:
	var state := PlayerRuntimeState.new()

	_setup_vitals(
		state
	)

	_setup_experience(
		state
	)

	_setup_skills(
		state
	)

	_setup_currency(
		state
	)


	return state

# =========================================================
# VITALES
# =========================================================

static func _setup_vitals(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.vitals == null:
		return


	state.vitals.set_max_hp(
		DEFAULT_MAX_HP
	)

	state.vitals.set_hp(
		DEFAULT_MAX_HP
	)


	state.vitals.set_max_mp(
		DEFAULT_MAX_MP
	)

	state.vitals.set_mp(
		DEFAULT_MAX_MP
	)

# =========================================================
# EXPERIENCIA
# =========================================================

static func _setup_experience(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.experience == null:
		return


	state.experience.set_experience_required(
		DEFAULT_EXPERIENCE_REQUIRED
	)


	state.experience.set_experience(
		DEFAULT_EXPERIENCE
	)

# =========================================================
# INVENTARIO
# =========================================================

static func _setup_inventory(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.inventory == null:
		return


	var sword_definition := (
		BRONZE_SWORD
		as ItemDefinition
	)

	var potion_definition := (
		HEALTH_POTION
		as ItemDefinition
	)


	if sword_definition == null:
		return


	if potion_definition == null:
		return


	state.inventory.create_item(
		potion_definition,
		40,
		Vector2i(
			6,
			3
		),
		"debug_potion_b"
	)


	state.inventory.create_item(
		sword_definition,
		1,
		Vector2i(
			2,
			1
		),
		"debug_sword_a"
	)


	state.inventory.create_item(
		sword_definition,
		1,
		Vector2i(
			4,
			2
		),
		"debug_sword_b"
	)


	state.inventory.create_item(
		potion_definition,
		25,
		Vector2i(
			6,
			1
		),
		"debug_potion_a"
	)


# =========================================================
# SKILLS
# =========================================================

static func _setup_skills(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.skill_book == null:
		return


	if state.skill_hotbar == null:
		return


	var fire_ball := (
		FIRE_BALL
		as SkillDefinition
	)

	var poison := (
		POISON
		as SkillDefinition
	)

	var heal := (
		HEAL
		as SkillDefinition
	)


	if (
		fire_ball == null
		or
		poison == null
		or
		heal == null
	):
		return


	# -----------------------------------------------------
	# SKILL BOOK
	# -----------------------------------------------------

	state.skill_book.learn_skill(
		fire_ball
	)

	state.skill_book.learn_skill(
		poison
	)

	state.skill_book.learn_skill(
		heal
	)


	# -----------------------------------------------------
	# HOTBAR
	# -----------------------------------------------------

	state.skill_hotbar.set_skill(
		0,
		fire_ball
	)

	state.skill_hotbar.set_skill(
		1,
		poison
	)

	state.skill_hotbar.set_skill(
		2,
		heal
	)


# =========================================================
# CURRENCY
# =========================================================

static func _setup_currency(
	state: PlayerRuntimeState
) -> void:
	if state == null:
		return


	if state.currency == null:
		return


	state.currency.set_zen(
		DEFAULT_ZEN
	)
