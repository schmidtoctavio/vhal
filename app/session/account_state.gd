class_name AccountState
extends RefCounted


# =========================================================
# CONFIGURACIÓN
# =========================================================

const VAULT_COLUMNS: int = 8
const VAULT_ROWS: int = 16


# =========================================================
# VAULT
# =========================================================

var vault: InventoryData = null


# =========================================================
# CONSTRUCTOR
# =========================================================

func _init() -> void:
	vault = InventoryData.new(
		VAULT_COLUMNS,
		VAULT_ROWS
	)
