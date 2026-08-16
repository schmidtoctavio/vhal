@tool
class_name VaultWindow
extends BaseWindow


# =========================================================
# REFERENCIAS
# =========================================================

@onready var inventory_grid: InventoryGrid = (
	$ContentMargin/Content/Body/BagPanel/BagMargin/GridCenter/InventoryGrid
)


# =========================================================
# MODELO
# =========================================================

var vault_data: InventoryData = null


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	super._ready()


	if Engine.is_editor_hint():
		return


	_apply_vault_data()


# =========================================================
# BIND
# =========================================================

func bind_vault_data(
	data: InventoryData
) -> void:
	vault_data = data


	if is_node_ready():
		_apply_vault_data()


func _apply_vault_data() -> void:
	inventory_grid.bind_inventory_data(
		vault_data
	)
