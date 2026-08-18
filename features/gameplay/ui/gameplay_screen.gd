class_name GameplayScreen
extends Control


# =========================================================
# PLAYER ACTOR
# =========================================================

const PLAYER_ACTOR_SCENE: PackedScene = preload(
	"res://features/player/runtime/player_actor.tscn"
)

const REMOTE_PLAYER_ACTOR_SCENE: PackedScene = preload(
	"res://features/player/runtime/remote_player_actor.tscn"
)

# =========================================================
# SEÑALES
# =========================================================

signal world_load_failed(
	message: String
)

signal player_spawn_failed(
	message: String
)

signal movement_intent_requested(
	target: Vector3
)

signal npc_interaction_requested(
	npc_id: String,
	service_id: String
)

# =========================================================
# REFERENCIAS
# =========================================================

@onready var world_root: Node3D = (
	$WorldRoot
)

@onready var map_root: Node3D = (
	$WorldRoot/MapRoot
)

@onready var actors_root: Node3D = (
	$WorldRoot/ActorsRoot
)

@onready var gameplay_ui: GameplayUI = (
	$GameplayUI
)

@onready var camera_controller: PlayerCameraController = (
	$WorldRoot/PlayerCameraController
)

@onready var player_input_controller: PlayerInputController = (
	$PlayerInputController
)

@onready var npc_interaction_controller: NpcInteractionController = (
	$NpcInteractionController
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
# PLAYER ACTIVO
# =========================================================

var active_player_actor: PlayerActor = null

# =========================================================
# PLAYERS REMOTOS
# =========================================================

var remote_player_actors: Dictionary = {}

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


	if not _prepare_gameplay():
		return


	_apply_states()

	_refresh_character_debug()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	if player_state != null:
		if not _prepare_gameplay():
			return


	_apply_states()

	_refresh_character_debug()


# =========================================================
# PREPARAR GAMEPLAY
# =========================================================

func _prepare_gameplay() -> bool:
	if not _load_world_from_state():
		return false


	if not _spawn_player_from_state():
		return false


	return true


# =========================================================
# CARGAR MUNDO
# =========================================================

func _load_world_from_state() -> bool:
	if world_root == null:
		world_load_failed.emit(
			"No existe el contenedor del mundo."
		)

		return false


	if map_root == null:
		world_load_failed.emit(
			"No existe el contenedor de mapas."
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


	map_root.add_child(
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
# SPAWN DEL PLAYER
# =========================================================

func _spawn_player_from_state() -> bool:
	if actors_root == null:
		player_spawn_failed.emit(
			"No existe el contenedor de actores."
		)

		return false


	if player_state == null:
		player_spawn_failed.emit(
			"No existe el estado del jugador."
		)

		return false


	if player_state.world == null:
		player_spawn_failed.emit(
			"No existe el estado del mundo del jugador."
		)

		return false


	_clear_active_player()


	var actor_instance: Node = (
		PLAYER_ACTOR_SCENE.instantiate()
	)


	if actor_instance == null:
		player_spawn_failed.emit(
			"No se pudo instanciar el actor del jugador."
		)

		return false


	var player_actor := (
		actor_instance
		as PlayerActor
	)


	if player_actor == null:
		actor_instance.free()


		player_spawn_failed.emit(
			"No se pudo crear el actor del jugador."
		)

		return false


	actors_root.add_child(
		player_actor
	)


	if not player_actor.setup(
		player_state
	):
		player_actor.queue_free()


		player_spawn_failed.emit(
			"No se pudo configurar el actor del jugador."
		)

		return false

	if camera_controller == null:
		player_actor.queue_free()


		player_spawn_failed.emit(
			"No existe el controlador de cámara."
		)

		return false

	if not camera_controller.setup(
		player_actor.camera_target
	):
		player_actor.queue_free()


		player_spawn_failed.emit(
			"No se pudo configurar la cámara del jugador."
		)

		return false

	if player_input_controller == null:
		player_actor.queue_free()


		player_spawn_failed.emit(
			"No existe el controlador de input del jugador."
		)

		return false

	if not player_input_controller.zoom_in_requested.is_connected(
		camera_controller.zoom_in
	):
		player_input_controller.zoom_in_requested.connect(
			camera_controller.zoom_in
		)


	if not player_input_controller.zoom_out_requested.is_connected(
		camera_controller.zoom_out
	):
		player_input_controller.zoom_out_requested.connect(
			camera_controller.zoom_out
		)

	if not player_input_controller.setup(
		player_actor,
		camera_controller.get_camera(),
		gameplay_ui
	):
		camera_controller.clear_target()

		player_actor.queue_free()


		player_spawn_failed.emit(
			"No se pudo configurar el controlador de input."
		)

		return false

	if npc_interaction_controller == null:
		player_actor.queue_free()


		player_spawn_failed.emit(
			"No existe el controlador de interacción con NPCs."
		)


		return false


	if not npc_interaction_controller.setup(
		player_actor
	):
		player_actor.queue_free()


		player_spawn_failed.emit(
			"No se pudo configurar la interacción con NPCs."
		)


		return false

	if not player_input_controller.move_target_requested.is_connected(
		_on_move_target_requested
	):
		player_input_controller.move_target_requested.connect(
			_on_move_target_requested
		)


	if not player_input_controller.npc_clicked.is_connected(
		_on_npc_clicked
	):
		player_input_controller.npc_clicked.connect(
			_on_npc_clicked
		)


	if not npc_interaction_controller.interaction_requested.is_connected(
		_on_npc_interaction_requested
	):
		npc_interaction_controller.interaction_requested.connect(
			_on_npc_interaction_requested
		)


	active_player_actor = player_actor


	return true


# =========================================================
# LIMPIAR PLAYER
# =========================================================

func _clear_active_player() -> void:
	if player_input_controller != null:
		player_input_controller.clear()

	if npc_interaction_controller != null:
		npc_interaction_controller.clear()

	if camera_controller != null:
		camera_controller.clear_target()

	if (
		active_player_actor != null
		and
		is_instance_valid(
			active_player_actor
		)
	):
		active_player_actor.queue_free()


	active_player_actor = null


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

# =========================================================
# INTENCIÓN DE MOVIMIENTO
# =========================================================

func _on_move_target_requested(
	target: Vector3
) -> void:
	movement_intent_requested.emit(
		target
	)

# =========================================================
# ESTADO AUTORITATIVO DEL PLAYER
# =========================================================

func apply_authoritative_movement_state(
	authoritative_position: Vector3,
	rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	if active_player_actor == null:
		return


	if not is_instance_valid(
		active_player_actor
	):
		return


	active_player_actor.apply_authoritative_movement_state(
		authoritative_position,
		rotation_y,
		moving,
		sequence
	)

func apply_movement_decision(
	request_id: int,
	accepted: bool,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	authorized_target: Vector3,
	reason: String
) -> void:
	if active_player_actor == null:
		return


	if not is_instance_valid(
		active_player_actor
	):
		return


	active_player_actor.apply_movement_decision(
		request_id,
		accepted,
		authoritative_position,
		authoritative_rotation_y,
		authorized_target,
		reason
	)

# =========================================================
# SINCRONIZAR PLAYERS REMOTOS
# =========================================================

func sync_remote_players(
	players: Array
) -> void:
	_clear_remote_players()


	for player_value: Variant in players:
		if typeof(player_value) != TYPE_DICTIONARY:
			continue


		var player: Dictionary = (
			player_value
		)


		_spawn_or_update_remote_player(
			player
		)


	print(
		"GameplayScreen | Remotos sincronizados",
		" | Cantidad: ",
		remote_player_actors.size()
	)


# =========================================================
# PLAYER REMOTO ENTRÓ
# =========================================================

func apply_remote_player_joined(
	player: Dictionary
) -> void:
	_spawn_or_update_remote_player(
		player
	)


# =========================================================
# PLAYER REMOTO SALIÓ
# =========================================================

func apply_remote_player_left(
	peer_id: int
) -> void:
	if not remote_player_actors.has(
		peer_id
	):
		return


	var actor_value: Variant = (
		remote_player_actors[
			peer_id
		]
	)


	var remote_actor := (
		actor_value
		as RemotePlayerActor
	)


	remote_player_actors.erase(
		peer_id
	)


	if (
		remote_actor != null
		and
		is_instance_valid(
			remote_actor
		)
	):
		remote_actor.queue_free()


	print(
		"GameplayScreen | Player remoto eliminado",
		" | Peer: ",
		peer_id
	)


# =========================================================
# CREAR / ACTUALIZAR PLAYER REMOTO
# =========================================================

func _spawn_or_update_remote_player(
	player: Dictionary
) -> void:
	if actors_root == null:
		return


	var peer_id := int(
		player.get(
			"peer_id",
			-1
		)
	)


	if peer_id <= 1:
		return


	if player_state == null:
		return


	if player_state.world == null:
		return


	var world_value: Variant = (
		player.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return


	var world: Dictionary = (
		world_value
	)


	var remote_map_id := String(
		world.get(
			"map_id",
			""
		)
	).strip_edges()


	if (
		remote_map_id
		!=
		player_state.world.map_id
	):
		return


	# -----------------------------------------------------
	# YA EXISTE
	# -----------------------------------------------------

	if remote_player_actors.has(
		peer_id
	):
		var existing_value: Variant = (
			remote_player_actors[
				peer_id
			]
		)


		var existing_actor := (
			existing_value
			as RemotePlayerActor
		)


		if (
			existing_actor != null
			and
			is_instance_valid(
				existing_actor
			)
		):
			existing_actor.setup(
				player
			)


		return


	# -----------------------------------------------------
	# INSTANCIAR
	# -----------------------------------------------------

	var actor_instance: Node = (
		REMOTE_PLAYER_ACTOR_SCENE.instantiate()
	)


	if actor_instance == null:
		return


	var remote_actor := (
		actor_instance
		as RemotePlayerActor
	)


	if remote_actor == null:
		actor_instance.free()

		return


	remote_actor.name = (
		"RemotePlayer_%d"
		% peer_id
	)


	actors_root.add_child(
		remote_actor
	)


	if not remote_actor.setup(
		player
	):
		remote_actor.queue_free()

		return


	remote_player_actors[
		peer_id
	] = remote_actor


	print(
		"GameplayScreen | Player remoto instanciado",
		" | Peer: ",
		peer_id,
		" | Personaje: ",
		remote_actor.character_name
	)


# =========================================================
# LIMPIAR PLAYERS REMOTOS
# =========================================================

func _clear_remote_players() -> void:
	for actor_value: Variant in remote_player_actors.values():
		var remote_actor := (
			actor_value
			as RemotePlayerActor
		)


		if (
			remote_actor == null
			or
			not is_instance_valid(
				remote_actor
			)
		):
			continue


		remote_actor.queue_free()


	remote_player_actors.clear()

# =========================================================
# MOVIMIENTO DE PLAYER REMOTO
# =========================================================

func apply_remote_player_movement_state(
	peer_id: int,
	authoritative_position: Vector3,
	authoritative_rotation_y: float,
	moving: bool,
	sequence: int
) -> void:
	if not remote_player_actors.has(
		peer_id
	):
		return


	var actor_value: Variant = (
		remote_player_actors[
			peer_id
		]
	)


	var remote_actor := (
		actor_value
		as RemotePlayerActor
	)


	if (
		remote_actor == null
		or
		not is_instance_valid(
			remote_actor
		)
	):
		return


	remote_actor.apply_authoritative_movement_state(
		authoritative_position,
		authoritative_rotation_y,
		moving,
		sequence
	)

# =========================================================
# CLICK SOBRE NPC
# =========================================================

func _on_npc_clicked(
	npc_actor: NpcActor
) -> void:
	if npc_interaction_controller == null:
		return


	npc_interaction_controller.request_interaction(
		npc_actor
	)


# =========================================================
# INTERACCIÓN NPC VALIDADA
# =========================================================

func _on_npc_interaction_requested(
	npc_id: String,
	service_id: String
) -> void:
	print(
		"GameplayScreen | Interacción NPC solicitada",
		" | NPC: ",
		npc_id,
		" | Servicio: ",
		service_id
	)


	npc_interaction_requested.emit(
		npc_id,
		service_id
	)
