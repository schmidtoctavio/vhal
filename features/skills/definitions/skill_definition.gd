@tool
class_name SkillDefinition
extends Resource


# =========================================================
# IDENTIDAD
# =========================================================

@export_group("Identity")

@export var skill_id: StringName = &"skill"

@export var display_name: String = "Skill"

@export_multiline var description: String = ""

@export var icon: Texture2D

# =========================================================
# TARGETING
# =========================================================

const TARGET_SELF: String = "self"

const TARGET_ENTITY: String = "entity"


@export_group("Targeting")

@export_enum(
	"self",
	"entity"
)
var target_kind: String = TARGET_SELF

# =========================================================
# COSTOS
# =========================================================

@export_group("Cost")

@export_range(0, 99999, 1)
var mana_cost: int = 0


# =========================================================
# COOLDOWN
# =========================================================

@export_group("Cooldown")

@export_range(0.0, 60.0, 0.1)
var cooldown_duration: float = 0.0
