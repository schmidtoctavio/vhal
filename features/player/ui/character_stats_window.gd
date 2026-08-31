@tool
class_name CharacterStatsWindow
extends BaseWindow


# =========================================================
# SEÑALES
# =========================================================

signal primary_stat_allocation_requested(
	stat_id: String,
	points: int
)


# =========================================================
# REFERENCIAS — VALORES
# =========================================================

@onready var strength_value_label: Label = (
	$ContentMargin/Content/Body/StatsContent/StrengthRow/ValueLabel
)

@onready var agility_value_label: Label = (
	$ContentMargin/Content/Body/StatsContent/AgilityRow/ValueLabel
)

@onready var vitality_value_label: Label = (
	$ContentMargin/Content/Body/StatsContent/VitalityRow/ValueLabel
)

@onready var energy_value_label: Label = (
	$ContentMargin/Content/Body/StatsContent/EnergyRow/ValueLabel
)

@onready var available_points_value_label: Label = (
	$ContentMargin/Content/Body/StatsContent/AvailablePointsRow/ValueLabel
)

@onready var allocation_feedback_label: Label = (
	$ContentMargin/Content/Body/StatsContent/AllocationFeedbackLabel
)


# =========================================================
# REFERENCIAS — ALLOCATION
# =========================================================

@onready var strength_add_button: Button = (
	$ContentMargin/Content/Body/StatsContent/StrengthRow/AddButton
)

@onready var agility_add_button: Button = (
	$ContentMargin/Content/Body/StatsContent/AgilityRow/AddButton
)

@onready var vitality_add_button: Button = (
	$ContentMargin/Content/Body/StatsContent/VitalityRow/AddButton
)

@onready var energy_add_button: Button = (
	$ContentMargin/Content/Body/StatsContent/EnergyRow/AddButton
)


# =========================================================
# MODELO
# =========================================================

var primary_stats: PrimaryStatsState = null


# =========================================================
# ESTADO DE ALLOCATION
# =========================================================

var allocation_pending: bool = false


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	super._ready()


	if Engine.is_editor_hint():
		return


	if not strength_add_button.pressed.is_connected(
		_on_strength_add_pressed
	):
		strength_add_button.pressed.connect(
			_on_strength_add_pressed
		)


	if not agility_add_button.pressed.is_connected(
		_on_agility_add_pressed
	):
		agility_add_button.pressed.connect(
			_on_agility_add_pressed
		)


	if not vitality_add_button.pressed.is_connected(
		_on_vitality_add_pressed
	):
		vitality_add_button.pressed.connect(
			_on_vitality_add_pressed
		)


	if not energy_add_button.pressed.is_connected(
		_on_energy_add_pressed
	):
		energy_add_button.pressed.connect(
			_on_energy_add_pressed
		)


	_refresh_from_state()


func _exit_tree() -> void:
	_disconnect_primary_stats()


# =========================================================
# BIND
# =========================================================

func bind_primary_stats(
	state: PrimaryStatsState
) -> void:
	if primary_stats == state:
		if is_node_ready():
			_refresh_from_state()


		return


	_disconnect_primary_stats()


	allocation_pending = false

	primary_stats = state


	if primary_stats != null:
		if not primary_stats.primary_stats_changed.is_connected(
			_on_primary_stats_changed
		):
			primary_stats.primary_stats_changed.connect(
				_on_primary_stats_changed
			)


	if is_node_ready():
		allocation_feedback_label.text = ""

		_refresh_from_state()


# =========================================================
# DESCONECTAR MODELO
# =========================================================

func _disconnect_primary_stats() -> void:
	if primary_stats == null:
		return


	if primary_stats.primary_stats_changed.is_connected(
		_on_primary_stats_changed
	):
		primary_stats.primary_stats_changed.disconnect(
			_on_primary_stats_changed
		)


# =========================================================
# CAMBIO AUTORITATIVO
# =========================================================

func _on_primary_stats_changed(
	_snapshot: Dictionary
) -> void:
	allocation_pending = false


	_refresh_from_state()


# =========================================================
# RESULTADO DE ALLOCATION
# =========================================================

func apply_primary_stat_allocation_result(
	request_id: int,
	accepted: bool,
	stat_id: String,
	points: int,
	reason: String
) -> void:
	if request_id <= 0:
		return


	allocation_pending = false


	if accepted:
		allocation_feedback_label.text = (
			"%s +%d APLICADA"
			% [
				_get_stat_display_name(
					stat_id
				),
				points,
			]
		)
	else:
		allocation_feedback_label.text = (
			_get_rejection_message(
				reason
			)
		)


	_refresh_allocation_controls()


# =========================================================
# REFRESCAR UI
# =========================================================

func _refresh_from_state() -> void:
	if not is_node_ready():
		return


	if primary_stats == null:
		strength_value_label.text = "-"

		agility_value_label.text = "-"

		vitality_value_label.text = "-"

		energy_value_label.text = "-"

		available_points_value_label.text = "-"


		_refresh_allocation_controls()


		return


	strength_value_label.text = str(
		primary_stats.permanent_strength
	)

	agility_value_label.text = str(
		primary_stats.permanent_agility
	)

	vitality_value_label.text = str(
		primary_stats.permanent_vitality
	)

	energy_value_label.text = str(
		primary_stats.permanent_energy
	)

	available_points_value_label.text = str(
		primary_stats.unspent_points
	)


	_refresh_allocation_controls()


# =========================================================
# CONTROLES DE ALLOCATION
# =========================================================

func _refresh_allocation_controls() -> void:
	var should_disable: bool = true


	if primary_stats != null:
		should_disable = (
			allocation_pending
			or
			primary_stats.unspent_points <= 0
		)


	strength_add_button.disabled = should_disable

	agility_add_button.disabled = should_disable

	vitality_add_button.disabled = should_disable

	energy_add_button.disabled = should_disable


# =========================================================
# REQUEST DE ALLOCATION
# =========================================================

func _request_primary_stat_allocation(
	stat_id: String
) -> void:
	if allocation_pending:
		return


	if primary_stats == null:
		return


	if primary_stats.unspent_points <= 0:
		return


	allocation_pending = true


	allocation_feedback_label.text = (
		"APLICANDO %s..."
		% _get_stat_display_name(
			stat_id
		)
	)


	_refresh_allocation_controls()


	primary_stat_allocation_requested.emit(
		stat_id,
		1
	)


# =========================================================
# DISPLAY DE STAT
# =========================================================

func _get_stat_display_name(
	stat_id: String
) -> String:
	match stat_id.strip_edges().to_lower():
		"strength":
			return "FUERZA"

		"agility":
			return "AGILIDAD"

		"vitality":
			return "VITALIDAD"

		"energy":
			return "ENERGÍA"

		_:
			return "ATRIBUTO"


# =========================================================
# FEEDBACK DE RECHAZO
# =========================================================

func _get_rejection_message(
	reason: String
) -> String:
	match reason.strip_edges().to_lower():
		"insufficient_points":
			return "PUNTOS INSUFICIENTES"

		"allocation_busy":
			return "ASIGNACIÓN EN PROCESO"

		"stale_request":
			return "SOLICITUD DESACTUALIZADA"

		"stale_revision":
			return "ATRIBUTOS ACTUALIZADOS"

		"invalid_points":
			return "CANTIDAD DE PUNTOS INVÁLIDA"

		"invalid_stat":
			return "ATRIBUTO INVÁLIDO"

		_:
			return "NO SE PUDO ASIGNAR EL PUNTO"


# =========================================================
# BOTONES
# =========================================================

func _on_strength_add_pressed() -> void:
	_request_primary_stat_allocation(
		"strength"
	)


func _on_agility_add_pressed() -> void:
	_request_primary_stat_allocation(
		"agility"
	)


func _on_vitality_add_pressed() -> void:
	_request_primary_stat_allocation(
		"vitality"
	)


func _on_energy_add_pressed() -> void:
	_request_primary_stat_allocation(
		"energy"
	)
