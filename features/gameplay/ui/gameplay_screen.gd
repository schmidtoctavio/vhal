class_name GameplayScreen
extends Control

# =========================================================
# SEÑALES
# =========================================================

signal world_load_failed(
	message: String
)

# =========================================================
# REFERENCIAS
# =========================================================

@onready var world_root: Node3D = (
	$WorldRoot
)

@onready var gameplay_ui: GameplayUI = (
	$GameplayUI
)


# =========================================================
# ESTADO DEL JUGADOR
# =========================================================

var player_state: PlayerRuntimeState = null


# =========================================================
# ESTADO DE CUENTA
# =========================================================

var account_state: AccountState = null

# =========================================================
# ESTADO DEL MUNDO
# =========================================================

var active_map: Node3D = null

var active_map_definition: MapDefinition = null

# =========================================================
# CONFIGURACIÓN
# =========================================================

func setup(
	state: PlayerRuntimeState,
	new_account_state: AccountState
) -> void:
	player_state = state

	account_state = new_account_state


	if not is_node_ready():
		return


	if not _load_world_from_state():
		return


	_apply_states()

	_refresh_character_debug()

# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	if player_state != null:
		if not _load_world_from_state():
			return


	_apply_states()

	_refresh_character_debug()

# =========================================================
# CARGAR MUNDO
# =========================================================

func _load_world_from_state() -> bool:
	if world_root == null:
		world_load_failed.emit(
			"No existe el contenedor del mundo."
		)

		return false


	if player_state == null:
		world_load_failed.emit(
			"No existe el estado del jugador."
		)

		return false


	if player_state.world == null:
		world_load_failed.emit(
			"No existe el estado del mundo."
		)

		return false


	var map_id := (
		player_state.world.map_id.strip_edges()
	)


	if map_id.is_empty():
		world_load_failed.emit(
			"El snapshot no contiene un mapa válido."
		)

		return false


	var map_definition := (
		MapCatalog.get_definition(
			map_id
		)
	)


	if map_definition == null:
		world_load_failed.emit(
			"No existe la definición del mapa '%s'."
			% map_id
		)

		return false


	if map_definition.scene == null:
		world_load_failed.emit(
			"El mapa '%s' no posee una escena."
			% map_id
		)

		return false


	var map_instance: Node = (
		map_definition.scene.instantiate()
	)


	if map_instance == null:
		world_load_failed.emit(
			"No se pudo instanciar el mapa '%s'."
			% map_id
		)

		return false


	var map_node := (
		map_instance
		as Node3D
	)


	if map_node == null:
		map_instance.free()


		world_load_failed.emit(
			"La escena del mapa '%s' no posee un root Node3D."
			% map_id
		)

		return false


	_clear_active_map()


	world_root.add_child(
		map_node
	)


	active_map = map_node

	active_map_definition = map_definition


	return true

# =========================================================
# LIMPIAR MUNDO
# =========================================================

func _clear_active_map() -> void:
	if (
		active_map != null
		and
		is_instance_valid(
			active_map
		)
	):
		active_map.queue_free()


	active_map = null

	active_map_definition = null

# =========================================================
# APLICAR ESTADOS
# =========================================================

func _apply_states() -> void:
	if player_state != null:
		gameplay_ui.bind_player_state(
			player_state
		)


	gameplay_ui.bind_account_state(
		account_state
	)


# =========================================================
# DEBUG TEMPORAL
# =========================================================

func _refresh_character_debug() -> void:
	if player_state == null:
		return


	if player_state.character_summary == null:
		return


	var character := (
		player_state.character_summary
	)


	print(
		"GAMEPLAY | Personaje: ",
		character.display_name,
		" | Clase: ",
		character.character_class,
		" | Nivel: ",
		character.level
	)
