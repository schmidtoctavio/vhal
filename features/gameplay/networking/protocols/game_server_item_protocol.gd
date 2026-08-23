class_name GameServerItemProtocol
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

signal vault_snapshot_received(
	snapshot: Dictionary
)

signal character_inventory_snapshot_received(
	snapshot: Dictionary
)

signal character_equipment_snapshot_received(
	snapshot: Dictionary
)


# =========================================================
# MENSAJES
# =========================================================

const MESSAGE_VAULT_SNAPSHOT: String = (
	"vault_snapshot"
)

const MESSAGE_VAULT_ITEM_MOVE_REQUEST: String = (
	"vault_item_move_request"
)

const MESSAGE_CHARACTER_INVENTORY_SNAPSHOT: String = (
	"character_inventory_snapshot"
)

const MESSAGE_CHARACTER_EQUIPMENT_SNAPSHOT: String = (
	"character_equipment_snapshot"
)

const MESSAGE_INVENTORY_ITEM_MOVE_REQUEST: String = (
	"inventory_item_move_request"
)

const MESSAGE_ITEM_CONTAINER_TRANSFER_REQUEST: String = (
	"item_container_transfer_request"
)

const MESSAGE_EQUIPMENT_EQUIP_REQUEST: String = (
	"equipment_equip_request"
)

const MESSAGE_EQUIPMENT_UNEQUIP_REQUEST: String = (
	"equipment_unequip_request"
)


# =========================================================
# DEPENDENCIAS
# =========================================================

var send_message: Callable = Callable()

var get_world_snapshot: Callable = Callable()

var fail_connection: Callable = Callable()


# =========================================================
# ESTADO
# =========================================================

var next_vault_item_move_request_id: int = 1

var vault_item_move_request_pending: bool = false

var next_inventory_item_move_request_id: int = 1

var inventory_item_move_request_pending: bool = false

var next_item_container_transfer_request_id: int = 1

var item_container_transfer_request_pending: bool = false

var item_container_transfer_inventory_synced: bool = false

var item_container_transfer_vault_synced: bool = false

var next_equipment_transfer_request_id: int = 1

var equipment_transfer_request_pending: bool = false

var equipment_transfer_inventory_synced: bool = false

var equipment_transfer_equipment_synced: bool = false


# =========================================================
# SETUP
# =========================================================

func setup(
	p_send_message: Callable,
	p_get_world_snapshot: Callable,
	p_fail_connection: Callable
) -> bool:
	if not p_send_message.is_valid():
		return false


	if not p_get_world_snapshot.is_valid():
		return false


	if not p_fail_connection.is_valid():
		return false


	send_message = p_send_message

	get_world_snapshot = p_get_world_snapshot

	fail_connection = p_fail_connection


	return true


# =========================================================
# PROCESAR MENSAJE
# =========================================================

func process_message(
	message_type: String,
	data_value: Variant
) -> bool:
	match message_type:
		MESSAGE_CHARACTER_INVENTORY_SNAPSHOT:
			if typeof(data_value) != TYPE_DICTIONARY:
				_fail_connection(
					"El snapshot de Inventory es inválido."
				)


				return true


			var inventory_data: Dictionary = (
				data_value
			)


			_process_character_inventory_snapshot(
				inventory_data
			)


			return true

		MESSAGE_CHARACTER_EQUIPMENT_SNAPSHOT:
			if typeof(data_value) != TYPE_DICTIONARY:
				_fail_connection(
					"El snapshot de Equipment es inválido."
				)


				return true


			var equipment_data: Dictionary = (
				data_value
			)


			_process_character_equipment_snapshot(
				equipment_data
			)


			return true

		MESSAGE_VAULT_SNAPSHOT:
			if typeof(data_value) == TYPE_DICTIONARY:
				var vault_data: Dictionary = (
					data_value
				)


				_process_vault_snapshot(
					vault_data
				)


			return true


	return false


# =========================================================
# MUTACIÓN DE ITEMS PENDIENTE
# =========================================================

func _has_item_mutation_pending() -> bool:
	return (
		vault_item_move_request_pending
		or
		inventory_item_move_request_pending
		or
		item_container_transfer_request_pending
		or
		equipment_transfer_request_pending
	)


# =========================================================
# SNAPSHOT DE VAULT
# =========================================================

func _process_vault_snapshot(
	snapshot: Dictionary
) -> void:
	var account_id := int(
		snapshot.get(
			"account_id",
			0
		)
	)


	var container := String(
		snapshot.get(
			"container",
			""
		)
	).strip_edges()


	var items_value: Variant = (
		snapshot.get(
			"items",
			null
		)
	)


	if account_id <= 0:
		return


	if container != "vault":
		return


	if typeof(items_value) != TYPE_ARRAY:
		return


	var items: Array = (
		items_value as Array
	)


	vault_item_move_request_pending = false


	print(
		"GameServerClient | Snapshot de Vault recibido",
		" | Cuenta: ",
		account_id,
		" | Items: ",
		items.size()
	)


	vault_snapshot_received.emit(
		snapshot.duplicate(
			true
		)
	)


	_mark_item_container_transfer_vault_synced()


# =========================================================
# MOVER ITEM DE VAULT
# =========================================================

func send_vault_item_move_request(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> Error:
	if _has_item_mutation_pending():
		return ERR_BUSY


	var normalized_uid := (
		uid.strip_edges()
	)


	if normalized_uid.is_empty():
		return ERR_INVALID_PARAMETER


	if (
		current_position.x < 0
		or
		current_position.x >= 8
		or
		current_position.y < 0
		or
		current_position.y >= 16
	):
		return ERR_INVALID_PARAMETER


	if (
		new_position.x < 0
		or
		new_position.x >= 8
		or
		new_position.y < 0
		or
		new_position.y >= 16
	):
		return ERR_INVALID_PARAMETER


	if current_position == new_position:
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_vault_item_move_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_VAULT_ITEM_MOVE_REQUEST,
			{
				"request_id": request_id,
				"uid": normalized_uid,
				"current_grid_position": {
					"x": current_position.x,
					"y": current_position.y,
				},
				"new_grid_position": {
					"x": new_position.x,
					"y": new_position.y,
				},
			}
		)
	)


	if result != OK:
		return result as Error


	vault_item_move_request_pending = true

	next_vault_item_move_request_id += 1


	print(
		"GameServerClient | Solicitud de movimiento Vault enviada",
		" | Request: ",
		request_id,
		" | UID: ",
		normalized_uid,
		" | Desde: ",
		current_position,
		" | Hacia: ",
		new_position
	)


	return OK


# =========================================================
# SNAPSHOT DE INVENTORY DEL PERSONAJE
# =========================================================

func _process_character_inventory_snapshot(
	snapshot: Dictionary
) -> void:
	var account_id := int(
		snapshot.get(
			"account_id",
			0
		)
	)


	var character_id := int(
		snapshot.get(
			"character_id",
			0
		)
	)


	var container := String(
		snapshot.get(
			"container",
			""
		)
	).strip_edges()


	var items_value: Variant = (
		snapshot.get(
			"items",
			null
		)
	)


	if account_id <= 0:
		_fail_connection(
			"Inventory sin cuenta válida."
		)


		return


	if character_id <= 0:
		_fail_connection(
			"Inventory sin personaje válido."
		)


		return


	if container != "inventory":
		_fail_connection(
			"Contenedor de Inventory inválido."
		)


		return


	if typeof(items_value) != TYPE_ARRAY:
		_fail_connection(
			"Items de Inventory inválidos."
		)


		return


	var latest_world_snapshot := (
		_get_world_snapshot()
	)


	if latest_world_snapshot.is_empty():
		_fail_connection(
			"Inventory recibido antes de la identidad de mundo."
		)


		return


	if int(
		latest_world_snapshot.get(
			"account_id",
			0
		)
	) != account_id:
		_fail_connection(
			"Inventory pertenece a otra cuenta."
		)


		return


	var world_character_value: Variant = (
		latest_world_snapshot.get(
			"character",
			null
		)
	)


	if typeof(world_character_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Identidad de personaje no disponible."
		)


		return


	var world_character: Dictionary = (
		world_character_value
	)


	if int(
		world_character.get(
			"id",
			0
		)
	) != character_id:
		_fail_connection(
			"Inventory pertenece a otro personaje."
		)


		return


	var items: Array = (
		items_value as Array
	)


	inventory_item_move_request_pending = false


	print(
		"GameServerClient | Snapshot de Inventory recibido",
		" | Cuenta: ",
		account_id,
		" | Character ID: ",
		character_id,
		" | Items: ",
		items.size()
	)


	character_inventory_snapshot_received.emit(
		snapshot.duplicate(
			true
		)
	)


	_mark_item_container_transfer_inventory_synced()

	_mark_equipment_transfer_inventory_synced()


# =========================================================
# SNAPSHOT DE EQUIPMENT DEL PERSONAJE
# =========================================================

func _process_character_equipment_snapshot(
	snapshot: Dictionary
) -> void:
	var account_id := int(
		snapshot.get(
			"account_id",
			0
		)
	)


	var character_id := int(
		snapshot.get(
			"character_id",
			0
		)
	)


	var container := String(
		snapshot.get(
			"container",
			""
		)
	).strip_edges()


	var items_value: Variant = (
		snapshot.get(
			"items",
			null
		)
	)


	if account_id <= 0:
		_fail_connection(
			"Equipment sin cuenta válida."
		)


		return


	if character_id <= 0:
		_fail_connection(
			"Equipment sin personaje válido."
		)


		return


	if container != "equipment":
		_fail_connection(
			"Contenedor de Equipment inválido."
		)


		return


	if typeof(items_value) != TYPE_ARRAY:
		_fail_connection(
			"Items de Equipment inválidos."
		)


		return


	var latest_world_snapshot := (
		_get_world_snapshot()
	)


	if latest_world_snapshot.is_empty():
		_fail_connection(
			"Equipment recibido antes de la identidad de mundo."
		)


		return


	if int(
		latest_world_snapshot.get(
			"account_id",
			0
		)
	) != account_id:
		_fail_connection(
			"Equipment pertenece a otra cuenta."
		)


		return


	var world_character_value: Variant = (
		latest_world_snapshot.get(
			"character",
			null
		)
	)


	if typeof(world_character_value) != TYPE_DICTIONARY:
		_fail_connection(
			"Identidad de personaje no disponible."
		)


		return


	var world_character: Dictionary = (
		world_character_value
	)


	if int(
		world_character.get(
			"id",
			0
		)
	) != character_id:
		_fail_connection(
			"Equipment pertenece a otro personaje."
		)


		return


	var items: Array = (
		items_value as Array
	)


	print(
		"GameServerClient | Snapshot de Equipment recibido",
		" | Cuenta: ",
		account_id,
		" | Character ID: ",
		character_id,
		" | Items: ",
		items.size()
	)


	character_equipment_snapshot_received.emit(
		snapshot.duplicate(
			true
		)
	)


	_mark_equipment_transfer_equipment_synced()


# =========================================================
# MOVER ITEM DE INVENTORY
# =========================================================

func send_inventory_item_move_request(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> Error:
	if _has_item_mutation_pending():
		return ERR_BUSY


	var normalized_uid := (
		uid.strip_edges()
	)


	if normalized_uid.is_empty():
		return ERR_INVALID_PARAMETER


	if normalized_uid.length() > 64:
		return ERR_INVALID_PARAMETER


	if (
		current_position.x < 0
		or
		current_position.x >= 8
		or
		current_position.y < 0
		or
		current_position.y >= 8
	):
		return ERR_INVALID_PARAMETER


	if (
		new_position.x < 0
		or
		new_position.x >= 8
		or
		new_position.y < 0
		or
		new_position.y >= 8
	):
		return ERR_INVALID_PARAMETER


	if current_position == new_position:
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_inventory_item_move_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_INVENTORY_ITEM_MOVE_REQUEST,
			{
				"request_id": request_id,
				"uid": normalized_uid,
				"current_grid_position": {
					"x": current_position.x,
					"y": current_position.y,
				},
				"new_grid_position": {
					"x": new_position.x,
					"y": new_position.y,
				},
			}
		)
	)


	if result != OK:
		return result as Error


	inventory_item_move_request_pending = true

	next_inventory_item_move_request_id += 1


	print(
		"GameServerClient | Solicitud de movimiento Inventory enviada",
		" | Request: ",
		request_id,
		" | UID: ",
		normalized_uid,
		" | Desde: ",
		current_position,
		" | Hacia: ",
		new_position
	)


	return OK


# =========================================================
# TRANSFERIR ITEM ENTRE INVENTORY Y VAULT
# =========================================================

func send_item_container_transfer_request(
	uid: String,
	source_container: String,
	target_container: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> Error:
	if _has_item_mutation_pending():
		return ERR_BUSY


	var normalized_uid := (
		uid.strip_edges()
	)


	var normalized_source := (
		source_container.strip_edges().to_lower()
	)


	var normalized_target := (
		target_container.strip_edges().to_lower()
	)


	if (
		normalized_uid.is_empty()
		or
		normalized_uid.length() > 64
	):
		return ERR_INVALID_PARAMETER


	if not _is_transfer_container(
		normalized_source
	):
		return ERR_INVALID_PARAMETER


	if not _is_transfer_container(
		normalized_target
	):
		return ERR_INVALID_PARAMETER


	if normalized_source == normalized_target:
		return ERR_INVALID_PARAMETER


	if not _is_position_inside_transfer_container(
		normalized_source,
		current_position
	):
		return ERR_INVALID_PARAMETER


	if not _is_position_inside_transfer_container(
		normalized_target,
		new_position
	):
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_item_container_transfer_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_ITEM_CONTAINER_TRANSFER_REQUEST,
			{
				"request_id": request_id,
				"uid": normalized_uid,
				"source_container": normalized_source,
				"target_container": normalized_target,
				"current_grid_position": {
					"x": current_position.x,
					"y": current_position.y,
				},
				"new_grid_position": {
					"x": new_position.x,
					"y": new_position.y,
				},
			}
		)
	)


	if result != OK:
		return result as Error


	item_container_transfer_request_pending = true

	item_container_transfer_inventory_synced = false

	item_container_transfer_vault_synced = false

	next_item_container_transfer_request_id += 1


	print(
		"GameServerClient | Transferencia Inventory/Vault enviada",
		" | Request: ",
		request_id,
		" | UID: ",
		normalized_uid,
		" | Desde: ",
		normalized_source,
		" ",
		current_position,
		" | Hacia: ",
		normalized_target,
		" ",
		new_position
	)


	return OK


# =========================================================
# CONTENEDOR SOPORTADO
# =========================================================

func _is_transfer_container(
	container: String
) -> bool:
	return (
		container == "inventory"
		or
		container == "vault"
	)


# =========================================================
# POSICIÓN VÁLIDA POR CONTENEDOR
# =========================================================

func _is_position_inside_transfer_container(
	container: String,
	position: Vector2i
) -> bool:
	if (
		position.x < 0
		or
		position.x >= 8
		or
		position.y < 0
	):
		return false


	match container:
		"inventory":
			return position.y < 8

		"vault":
			return position.y < 16


	return false


# =========================================================
# SNAPSHOT INVENTORY RECIBIDO DURANTE TRANSFERENCIA
# =========================================================

func _mark_item_container_transfer_inventory_synced() -> void:
	if not item_container_transfer_request_pending:
		return


	item_container_transfer_inventory_synced = true


	_try_finish_item_container_transfer_sync()


# =========================================================
# SNAPSHOT VAULT RECIBIDO DURANTE TRANSFERENCIA
# =========================================================

func _mark_item_container_transfer_vault_synced() -> void:
	if not item_container_transfer_request_pending:
		return


	item_container_transfer_vault_synced = true


	_try_finish_item_container_transfer_sync()


# =========================================================
# FINALIZAR SINCRONIZACIÓN CROSS-CONTAINER
# =========================================================

func _try_finish_item_container_transfer_sync() -> void:
	if not item_container_transfer_request_pending:
		return


	if not item_container_transfer_inventory_synced:
		return


	if not item_container_transfer_vault_synced:
		return


	item_container_transfer_request_pending = false

	item_container_transfer_inventory_synced = false

	item_container_transfer_vault_synced = false


	print(
		"GameServerClient | Transferencia Inventory/Vault sincronizada."
	)


# =========================================================
# EQUIPAR ITEM DESDE INVENTORY
# =========================================================

func send_equipment_equip_request(
	uid: String,
	current_position: Vector2i,
	equipment_slot: Variant
) -> Error:
	if _has_item_mutation_pending():
		return ERR_BUSY


	var normalized_uid := (
		uid.strip_edges()
	)


	if (
		normalized_uid.is_empty()
		or
		normalized_uid.length() > 64
	):
		return ERR_INVALID_PARAMETER


	if (
		current_position.x < 0
		or
		current_position.x >= 8
		or
		current_position.y < 0
		or
		current_position.y >= 8
	):
		return ERR_INVALID_PARAMETER


	var normalized_slot := String(
		equipment_slot
	).strip_edges().to_lower()


	if (
		normalized_slot.is_empty()
		or
		normalized_slot.length() > 32
	):
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_equipment_transfer_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_EQUIPMENT_EQUIP_REQUEST,
			{
				"request_id": request_id,
				"uid": normalized_uid,
				"current_grid_position": {
					"x": current_position.x,
					"y": current_position.y,
				},
				"equipment_slot": normalized_slot,
			}
		)
	)


	if result != OK:
		return result as Error


	equipment_transfer_request_pending = true

	equipment_transfer_inventory_synced = false

	equipment_transfer_equipment_synced = false

	next_equipment_transfer_request_id += 1


	print(
		"GameServerClient | Solicitud Equip enviada",
		" | Request: ",
		request_id,
		" | UID: ",
		normalized_uid,
		" | Desde: ",
		current_position,
		" | Slot: ",
		normalized_slot
	)


	return OK


# =========================================================
# DESEQUIPAR ITEM HACIA INVENTORY
# =========================================================

func send_equipment_unequip_request(
	uid: String,
	current_equipment_slot: Variant,
	new_position: Vector2i
) -> Error:
	if _has_item_mutation_pending():
		return ERR_BUSY


	var normalized_uid := (
		uid.strip_edges()
	)


	if (
		normalized_uid.is_empty()
		or
		normalized_uid.length() > 64
	):
		return ERR_INVALID_PARAMETER


	var normalized_slot := String(
		current_equipment_slot
	).strip_edges().to_lower()


	if (
		normalized_slot.is_empty()
		or
		normalized_slot.length() > 32
	):
		return ERR_INVALID_PARAMETER


	if (
		new_position.x < 0
		or
		new_position.x >= 8
		or
		new_position.y < 0
		or
		new_position.y >= 8
	):
		return ERR_INVALID_PARAMETER


	var request_id := (
		next_equipment_transfer_request_id
	)


	var result := int(
		send_message.call(
			MESSAGE_EQUIPMENT_UNEQUIP_REQUEST,
			{
				"request_id": request_id,
				"uid": normalized_uid,
				"current_equipment_slot": normalized_slot,
				"new_grid_position": {
					"x": new_position.x,
					"y": new_position.y,
				},
			}
		)
	)


	if result != OK:
		return result as Error


	equipment_transfer_request_pending = true

	equipment_transfer_inventory_synced = false

	equipment_transfer_equipment_synced = false

	next_equipment_transfer_request_id += 1


	print(
		"GameServerClient | Solicitud Unequip enviada",
		" | Request: ",
		request_id,
		" | UID: ",
		normalized_uid,
		" | Slot: ",
		normalized_slot,
		" | Destino: ",
		new_position
	)


	return OK


# =========================================================
# INVENTORY RECIBIDO DURANTE EQUIPMENT TRANSFER
# =========================================================

func _mark_equipment_transfer_inventory_synced() -> void:
	if not equipment_transfer_request_pending:
		return


	equipment_transfer_inventory_synced = true


	_try_finish_equipment_transfer_sync()


# =========================================================
# EQUIPMENT RECIBIDO DURANTE EQUIPMENT TRANSFER
# =========================================================

func _mark_equipment_transfer_equipment_synced() -> void:
	if not equipment_transfer_request_pending:
		return


	equipment_transfer_equipment_synced = true


	_try_finish_equipment_transfer_sync()


# =========================================================
# FINALIZAR SINCRONIZACIÓN INVENTORY / EQUIPMENT
# =========================================================

func _try_finish_equipment_transfer_sync() -> void:
	if not equipment_transfer_request_pending:
		return


	if not equipment_transfer_inventory_synced:
		return


	if not equipment_transfer_equipment_synced:
		return


	equipment_transfer_request_pending = false

	equipment_transfer_inventory_synced = false

	equipment_transfer_equipment_synced = false


	print(
		"GameServerClient | Transferencia Inventory/Equipment sincronizada."
	)


# =========================================================
# SERVICIO NPC FINALIZADO
# =========================================================

func cancel_vault_related_mutations() -> void:
	vault_item_move_request_pending = false

	item_container_transfer_request_pending = false

	item_container_transfer_inventory_synced = false

	item_container_transfer_vault_synced = false


# =========================================================
# RESET
# =========================================================

func reset() -> void:
	next_vault_item_move_request_id = 1

	vault_item_move_request_pending = false

	next_inventory_item_move_request_id = 1

	inventory_item_move_request_pending = false

	next_item_container_transfer_request_id = 1

	item_container_transfer_request_pending = false

	item_container_transfer_inventory_synced = false

	item_container_transfer_vault_synced = false

	next_equipment_transfer_request_id = 1

	equipment_transfer_request_pending = false

	equipment_transfer_inventory_synced = false

	equipment_transfer_equipment_synced = false


# =========================================================
# WORLD SNAPSHOT
# =========================================================

func _get_world_snapshot() -> Dictionary:
	if not get_world_snapshot.is_valid():
		return {}


	var value: Variant = (
		get_world_snapshot.call()
	)


	if typeof(value) != TYPE_DICTIONARY:
		return {}


	var snapshot: Dictionary = (
		value
	)


	return snapshot


# =========================================================
# ERROR DE CONEXIÓN
# =========================================================

func _fail_connection(
	message: String
) -> void:
	if not fail_connection.is_valid():
		return


	fail_connection.call(
		message
	)
