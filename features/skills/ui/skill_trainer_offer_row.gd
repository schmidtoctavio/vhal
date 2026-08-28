class_name SkillTrainerOfferRow
extends PanelContainer


# =========================================================
# SIGNALS
# =========================================================

signal learn_requested(
	skill_id: String,
	scroll_uid: String
)


# =========================================================
# REFERENCIAS
# =========================================================

@onready var skill_icon: TextureRect = (
	$Margin/Content/SkillIcon
)

@onready var skill_name_label: Label = (
	$Margin/Content/Info/SkillNameLabel
)

@onready var requirements_label: Label = (
	$Margin/Content/Info/RequirementsLabel
)

@onready var status_label: Label = (
	$Margin/Content/Info/StatusLabel
)

@onready var learn_button: Button = (
	$Margin/Content/LearnButton
)


# =========================================================
# ESTADO
# =========================================================

var offer_snapshot: Dictionary = {}


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	if not learn_button.pressed.is_connected(
		_on_learn_button_pressed
	):
		learn_button.pressed.connect(
			_on_learn_button_pressed
		)


# =========================================================
# APLICAR OFERTA AUTORITATIVA
# =========================================================

func apply_offer(
	offer: Dictionary
) -> bool:
	if offer.is_empty():
		return false


	var skill_id := String(
		offer.get(
			"skill_id",
			""
		)
	).strip_edges().to_lower()


	var scroll_item_id := String(
		offer.get(
			"scroll_item_id",
			""
		)
	).strip_edges().to_lower()


	if skill_id.is_empty():
		return false


	if scroll_item_id.is_empty():
		return false


	var skill_definition := (
		ClientSkillCatalog.get_definition(
			skill_id
		)
	)


	if skill_definition == null:
		return false


	var scroll_definition := (
		ItemCatalog.get_definition(
			scroll_item_id
		)
	)


	if scroll_definition == null:
		return false


	var minimum_level := int(
		offer.get(
			"minimum_level",
			0
		)
	)


	var can_learn := bool(
		offer.get(
			"can_learn",
			false
		)
	)


	var reason := String(
		offer.get(
			"reason",
			""
		)
	).strip_edges().to_lower()


	offer_snapshot = offer.duplicate(
		true
	)


	skill_icon.texture = (
		skill_definition.icon
	)


	skill_icon.tooltip_text = (
		skill_definition.description
	)


	skill_name_label.text = (
		skill_definition.display_name
	)


	requirements_label.text = (
		"Nivel mínimo: %d\nRequiere: %s"
		%
		[
			minimum_level,
			scroll_definition.display_name,
		]
	)


	status_label.text = (
		_get_status_text(
			reason
		)
	)


	learn_button.disabled = (
		not can_learn
	)


	return true


# =========================================================
# ESTADO VISUAL
#
# El texto representa el reason AUTORITATIVO.
# No recalculamos requisitos en el cliente.
# =========================================================

func _get_status_text(
	reason: String
) -> String:
	match reason:
		"ok":
			return "Disponible para aprender"

		"skill_already_learned":
			return "Aprendida"

		"level_requirement_not_met":
			return "Nivel insuficiente"

		"scroll_required":
			return "Falta el Scroll requerido"

		_:
			return "No disponible"


# =========================================================
# APRENDER
#
# Esta intención sólo nace desde una oferta autoritativa
# del Skill Trainer.
#
# El Game Server vuelve a validar todos los requisitos
# antes de persistir cualquier aprendizaje.
# =========================================================

func _on_learn_button_pressed() -> void:
	if learn_button.disabled:
		return


	var skill_id := String(
		offer_snapshot.get(
			"skill_id",
			""
		)
	).strip_edges().to_lower()


	var scroll_uid := String(
		offer_snapshot.get(
			"scroll_uid",
			""
		)
	).strip_edges().to_lower()


	if skill_id.is_empty():
		return


	if scroll_uid.is_empty():
		return

	learn_button.disabled = true

	status_label.text = "Procesando..."


	learn_requested.emit(
		skill_id,
		scroll_uid
	)
