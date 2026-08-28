@tool
class_name SkillTrainerWindow
extends BaseWindow

# =========================================================
# ESCENAS
# =========================================================

const OFFER_ROW_SCENE := preload(
	"res://features/skills/ui/skill_trainer_offer_row.tscn"
)


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

@onready var trainer_info_label: Label = (
	$ContentMargin/Content/Body/TrainerContent/TrainerInfoLabel
)

@onready var offers_list: VBoxContainer = (
	$ContentMargin/Content/Body/TrainerContent/OffersScroll/OffersList
)


# =========================================================
# ESTADO
# =========================================================

var active_snapshot: Dictionary = {}


# =========================================================
# SNAPSHOT AUTORITATIVO
# =========================================================

func apply_authoritative_snapshot(
	snapshot: Dictionary
) -> bool:
	if snapshot.is_empty():
		return false


	var character_id := int(
		snapshot.get(
			"character_id",
			0
		)
	)


	var npc_id := String(
		snapshot.get(
			"npc_id",
			""
		)
	).strip_edges().to_lower()


	var service_id := String(
		snapshot.get(
			"service_id",
			""
		)
	).strip_edges().to_lower()


	var class_id := String(
		snapshot.get(
			"class_id",
			""
		)
	).strip_edges().to_lower()


	var level := int(
		snapshot.get(
			"level",
			0
		)
	)


	var offers_value: Variant = (
		snapshot.get(
			"offers",
			null
		)
	)


	if character_id <= 0:
		return false


	if npc_id.is_empty():
		return false


	if service_id != "skill_trainer":
		return false


	if class_id.is_empty():
		return false


	if level <= 0:
		return false


	if typeof(offers_value) != TYPE_ARRAY:
		return false


	_clear_offer_rows()


	active_snapshot = snapshot.duplicate(
		true
	)


	trainer_info_label.text = (
		"Clase: %s   •   Nivel: %d"
		%
		[
			class_id,
			level,
		]
	)


	var offers: Array = (
		offers_value as Array
	)


	for offer_value: Variant in offers:
		if typeof(offer_value) != TYPE_DICTIONARY:
			clear_authoritative_snapshot()

			return false


		var row := (
			OFFER_ROW_SCENE.instantiate()
			as SkillTrainerOfferRow
		)


		if row == null:
			clear_authoritative_snapshot()

			return false


		offers_list.add_child(
			row
		)


		if not row.apply_offer(
			offer_value as Dictionary
		):
			clear_authoritative_snapshot()

			return false


		if not row.learn_requested.is_connected(
			_on_offer_learn_requested
		):
			row.learn_requested.connect(
				_on_offer_learn_requested
			)


	return true


# =========================================================
# LIMPIAR
# =========================================================

func clear_authoritative_snapshot() -> void:
	active_snapshot = {}


	_clear_offer_rows()


	if is_node_ready():
		trainer_info_label.text = ""


func _clear_offer_rows() -> void:
	if not is_node_ready():
		return


	for child: Node in offers_list.get_children():
		offers_list.remove_child(
			child
		)

		child.queue_free()


# =========================================================
# CENTRAR
# =========================================================

func center_in_viewport() -> void:
	if not is_node_ready():
		return


	var viewport_size := (
		get_viewport()
		.get_visible_rect()
		.size
	)


	var target_position := (
		(
			viewport_size
			-
			size
		)
		*
		0.5
	)


	global_position = (
		_clamp_to_viewport(
			target_position
		)
	)


# =========================================================
# FORWARD DEL BOTÓN
#
# D3 conectará este signal hacia networking.
# =========================================================

func _on_offer_learn_requested(
	skill_id: String,
	scroll_uid: String
) -> void:
	learn_requested.emit(
		skill_id,
		scroll_uid
	)
