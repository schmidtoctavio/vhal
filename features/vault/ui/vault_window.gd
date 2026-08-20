@tool
class_name VaultWindow
extends BaseWindow

# =========================================================
# SEÑALES
# =========================================================

signal vault_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
)

signal item_container_transfer_requested(
	uid: String,
	source_container: String,
	target_container: String,
	current_position: Vector2i,
	new_position: Vector2i
)

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


	inventory_grid.set_authoritative_move_only(
		true
	)

	inventory_grid.set_authoritative_container_id(
		"vault"
	)

	if not inventory_grid.authoritative_item_move_requested.is_connected(
		_on_authoritative_item_move_requested
	):
		inventory_grid.authoritative_item_move_requested.connect(
			_on_authoritative_item_move_requested
		)

	if not inventory_grid.authoritative_item_transfer_requested.is_connected(
		_on_authoritative_item_transfer_requested
	):
		inventory_grid.authoritative_item_transfer_requested.connect(
			_on_authoritative_item_transfer_requested
		)

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


# =========================================================
# MOVIMIENTO AUTORITATIVO SOLICITADO
# =========================================================

func _on_authoritative_item_move_requested(
	item: ItemInstance,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	if item == null:
		return


	var uid := (
		item.uid.strip_edges()
	)


	if uid.is_empty():
		return


	vault_item_move_requested.emit(
		uid,
		current_position,
		new_position
	)

func _on_authoritative_item_transfer_requested(
	item: ItemInstance,
	source_container: String,
	target_container: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	if item == null:
		return


	var uid := (
		item.uid.strip_edges()
	)


	if uid.is_empty():
		return


	item_container_transfer_requested.emit(
		uid,
		source_container,
		target_container,
		current_position,
		new_position
	)
