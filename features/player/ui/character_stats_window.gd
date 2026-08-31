@tool
class_name CharacterStatsWindow
extends BaseWindow


# =========================================================
# REFERENCIAS
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


# =========================================================
# MODELO
# =========================================================

var primary_stats: PrimaryStatsState = null


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	super._ready()


	if Engine.is_editor_hint():
		return


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


	primary_stats = state


	if primary_stats != null:
		if not primary_stats.primary_stats_changed.is_connected(
			_on_primary_stats_changed
		):
			primary_stats.primary_stats_changed.connect(
				_on_primary_stats_changed
			)


	if is_node_ready():
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
	_refresh_from_state()


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
