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

const MOB_ACTOR_SCENE: PackedScene = preload(
	"res://features/world/mobs/mob_actor.tscn"
)

const WORLD_DROP_ACTOR_SCENE: PackedScene = preload(
	"res://features/world/drops/world_drop_actor.tscn"
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

signal skill_cast_intent_requested(
	skill_id: String,
	target: Dictionary
)

signal skill_learning_intent_requested(
	skill_id: String,
	scroll_uid: String
)

signal basic_attack_intent_requested(
	target: Dictionary
)

signal npc_interaction_requested(
	npc_id: String,
	service_id: String
)

signal npc_service_end_requested

signal vault_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
)

signal inventory_item_move_requested(
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

signal equipment_item_equip_requested(
	uid: String,
	current_position: Vector2i,
	target_slot_id: StringName
)


signal equipment_item_unequip_requested(
	uid: String,
	source_slot_id: StringName,
	new_position: Vector2i
)

signal world_drop_pickup_intent_requested(
	entity_id: String
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

@onready var drops_root: Node3D = (
	$WorldRoot/DropsRoot
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
# SERVICIO NPC PENDIENTE DE DATOS
# =========================================================

var pending_authorized_npc_id: String = ""
var pending_authorized_service_id: String = ""

var authorized_vault_active: bool = false
var authorized_skill_trainer_active: bool = false
var authorized_skill_trainer_npc_id: String = ""

# =========================================================
# ESTADO DEL MUNDO
# =========================================================

var active_map: Node3D = null

var active_map_definition: MapDefinition = null

var world_drop_actors: Dictionary = {}


# =========================================================
# PLAYER ACTIVO
# =========================================================

var active_player_actor: PlayerActor = null

# =========================================================
# PLAYERS REMOTOS
# =========================================================

var remote_player_actors: Dictionary = {}

var mob_actors: Dictionary = {}

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

	if not gameplay_ui.authorized_vault_closed.is_connected(
		_on_authorized_vault_closed
	):
		gameplay_ui.authorized_vault_closed.connect(
			_on_authorized_vault_closed
		)

	if not gameplay_ui.item_container_transfer_requested.is_connected(
		_on_item_container_transfer_requested
	):
		gameplay_ui.item_container_transfer_requested.connect(
			_on_item_container_transfer_requested
		)

	if player_state != null:
		if not _prepare_gameplay():
			return

	if not gameplay_ui.vault_item_move_requested.is_connected(
		_on_vault_item_move_requested
	):
		gameplay_ui.vault_item_move_requested.connect(
			_on_vault_item_move_requested
		)

	if not gameplay_ui.inventory_item_move_requested.is_connected(
		_on_inventory_item_move_requested
	):
		gameplay_ui.inventory_item_move_requested.connect(
			_on_inventory_item_move_requested
		)

	if not gameplay_ui.equipment_item_equip_requested.is_connected(
		_on_equipment_item_equip_requested
	):
		gameplay_ui.equipment_item_equip_requested.connect(
			_on_equipment_item_equip_requested
		)


	if not gameplay_ui.equipment_item_unequip_requested.is_connected(
		_on_equipment_item_unequip_requested
	):
		gameplay_ui.equipment_item_unequip_requested.connect(
			_on_equipment_item_unequip_requested
		)

	if not gameplay_ui.inventory_item_activation_requested.is_connected(
		_on_inventory_item_activation_requested
	):
		gameplay_ui.inventory_item_activation_requested.connect(
			_on_inventory_item_activation_requested
		)

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

	if not player_input_controller.world_drop_pickup_requested.is_connected(
		_on_world_drop_pickup_requested
	):
		player_input_controller.world_drop_pickup_requested.connect(
			_on_world_drop_pickup_requested
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

	if not player_input_controller.skill_cast_requested.is_connected(
		_on_skill_cast_requested
	):
		player_input_controller.skill_cast_requested.connect(
			_on_skill_cast_requested
		)

	if not player_input_controller.basic_attack_requested.is_connected(
		_on_basic_attack_requested
	):
		player_input_controller.basic_attack_requested.connect(
			_on_basic_attack_requested
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
# INTENCIÓN DE BASIC ATTACK
# =========================================================

func _on_basic_attack_requested(
	target_entity_id: String
) -> void:
	var entity_id := (
		target_entity_id
		.strip_edges()
		.to_lower()
	)


	if entity_id.is_empty():
		return


	print(
		"GameplayScreen | Basic Attack solicitado",
		" | Entity: ",
		entity_id
	)


	basic_attack_intent_requested.emit(
		{
			"kind": "entity",

			"entity_id": entity_id,
		}
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
# INTENCIÓN DE CAST
# =========================================================

func _on_skill_cast_requested(
	_screen_position: Vector2,
	target_entity_id: String
) -> void:
	if player_state == null:
		return


	if player_state.skill_hotbar == null:
		return


	var skill := (
		player_state
		.skill_hotbar
		.get_selected_skill()
	)


	if skill == null:
		return


	var skill_id := String(
		skill.skill_id
	).strip_edges().to_lower()


	if skill_id.is_empty():
		return


	var target_kind := String(
		skill.target_kind
	).strip_edges().to_lower()


	var target: Dictionary = {}


	# -----------------------------------------------------
	# SELF
	# -----------------------------------------------------

	if (
		target_kind
		==
		SkillDefinition.TARGET_SELF
	):
		target = {
			"kind": "self",
		}


	# -----------------------------------------------------
	# ENTITY
	# -----------------------------------------------------

	elif (
		target_kind
		==
		SkillDefinition.TARGET_ENTITY
	):
		var normalized_entity_id := (
			target_entity_id
			.strip_edges()
			.to_lower()
		)


		if normalized_entity_id.is_empty():
			print(
				"GameplayScreen | Cast omitido",
				" | Skill: ",
				skill_id,
				" | Reason: entity_target_required"
			)


			return


		target = {
			"kind": "entity",

			"entity_id": (
				normalized_entity_id
			),
		}


	# -----------------------------------------------------
	# CONFIGURACIÓN DE SKILL INVÁLIDA
	# -----------------------------------------------------

	else:
		push_warning(
			(
				"GameplayScreen | "
				+
				"Target kind no soportado para skill '%s': %s"
			)
			%
			[
				skill_id,
				target_kind,
			]
		)


		return


	skill_cast_intent_requested.emit(
		skill_id,
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
# SINCRONIZAR MOBS
# =========================================================

func sync_world_mobs(
	mobs: Array
) -> void:
	_clear_world_mobs()


	for mob_value: Variant in mobs:
		if typeof(mob_value) != TYPE_DICTIONARY:
			continue


		var mob: Dictionary = (
			mob_value
		)


		_spawn_or_update_mob(
			mob
		)


	print(
		"GameplayScreen | Mobs sincronizados",
		" | Cantidad: ",
		mob_actors.size()
	)

# =========================================================
# ACTUALIZACIÓN AUTORITATIVA DE MOB
# =========================================================

func apply_mob_state_updated(
	mob: Dictionary
) -> void:
	if mob.is_empty():
		return


	_spawn_or_update_mob(
		mob
	)

# =========================================================
# CREAR / ACTUALIZAR MOB
# =========================================================

func _spawn_or_update_mob(
	mob: Dictionary
) -> void:
	if actors_root == null:
		return


	if player_state == null:
		return


	if player_state.world == null:
		return


	var entity_id := String(
		mob.get(
			"entity_id",
			""
		)
	).strip_edges().to_lower()


	if entity_id.is_empty():
		return


	var world_value: Variant = (
		mob.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return


	var world: Dictionary = (
		world_value
	)


	var mob_map_id := String(
		world.get(
			"map_id",
			""
		)
	).strip_edges()


	if (
		mob_map_id
		!=
		player_state.world.map_id
	):
		return


	# -----------------------------------------------------
	# YA EXISTE
	# -----------------------------------------------------

	if mob_actors.has(
		entity_id
	):
		var existing_value: Variant = (
			mob_actors[
				entity_id
			]
		)


		var existing_actor := (
			existing_value
			as MobActor
		)


		if (
			existing_actor != null
			and
			is_instance_valid(
				existing_actor
			)
		):
			existing_actor.setup(
				mob
			)


		return


	# -----------------------------------------------------
	# CREAR
	# -----------------------------------------------------

	var actor_instance := (
		MOB_ACTOR_SCENE.instantiate()
	)


	if actor_instance == null:
		return


	var mob_actor := (
		actor_instance
		as MobActor
	)


	if mob_actor == null:
		actor_instance.free()

		return


	actors_root.add_child(
		mob_actor
	)


	if not mob_actor.setup(
		mob
	):
		mob_actor.queue_free()

		return


	mob_actors[
		entity_id
	] = mob_actor


# =========================================================
# LIMPIAR MOBS
# =========================================================

func _clear_world_mobs() -> void:
	for actor_value: Variant in mob_actors.values():
		var mob_actor := (
			actor_value
			as MobActor
		)


		if (
			mob_actor != null
			and
			is_instance_valid(
				mob_actor
			)
		):
			mob_actor.queue_free()


	mob_actors.clear()

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

# =========================================================
# SERVICIO NPC AUTORIZADO
# =========================================================

func apply_authorized_npc_service(
	npc_id: String,
	service_id: String
) -> bool:
	var normalized_npc_id := (
		npc_id
		.strip_edges()
		.to_lower()
	)


	var normalized_service_id := (
		service_id
		.strip_edges()
		.to_lower()
	)


	if normalized_npc_id.is_empty():
		return false


	if normalized_service_id.is_empty():
		return false


	match normalized_service_id:

		# =================================================
		# WAREHOUSE
		# =================================================

		"warehouse":
			pending_authorized_npc_id = (
				normalized_npc_id
			)


			pending_authorized_service_id = (
				normalized_service_id
			)


			print(
				"GameplayScreen | Servicio NPC autorizado",
				" | NPC: ",
				normalized_npc_id,
				" | Servicio: ",
				normalized_service_id,
				" | Esperando snapshot persistente."
			)


			return true


		# =================================================
		# SKILL TRAINER
		#
		# No necesita snapshot extra para abrir una sesión.
		# La autorización ya vino del Game Server.
		# =================================================

		"skill_trainer":
			authorized_skill_trainer_active = true

			authorized_skill_trainer_npc_id = (
				normalized_npc_id
			)


			print(
				"GameplayScreen | Skill Trainer autorizado",
				" | NPC: ",
				authorized_skill_trainer_npc_id,
				" | Servicio: ",
				normalized_service_id
			)


			return true


		_:
			print(
				"GameplayScreen | Servicio NPC autorizado no soportado",
				" | NPC: ",
				normalized_npc_id,
				" | Servicio: ",
				normalized_service_id
			)


			return false

# =========================================================
# FINALIZAR SERVICIO NPC
# =========================================================

func _on_authorized_vault_closed() -> void:
	authorized_vault_active = false

	npc_service_end_requested.emit()

# =========================================================
# SERVICIO NPC FINALIZADO AUTORITATIVAMENTE
# =========================================================

func apply_authoritative_npc_service_end(
	npc_id: String,
	service_id: String,
	reason: String
) -> void:

	var normalized_npc_id := (
		npc_id.strip_edges()
	)


	var normalized_service_id := (
		service_id.strip_edges()
	)


	if (
		pending_authorized_npc_id
		==
		normalized_npc_id
		and
		pending_authorized_service_id
		==
		normalized_service_id
	):
		pending_authorized_npc_id = ""
		pending_authorized_service_id = ""

	match normalized_service_id:
		"warehouse":
			authorized_vault_active = false
			gameplay_ui.close_authorized_vault()


			print(
				"GameplayScreen | Servicio NPC cerrado autoritativamente",
				" | NPC: ",
				npc_id,
				" | Servicio: ",
				service_id,
				" | Motivo: ",
				reason
			)

		"skill_trainer":
			authorized_skill_trainer_active = false

			authorized_skill_trainer_npc_id = ""


			print(
				"GameplayScreen | Skill Trainer cerrado autoritativamente",
				" | NPC: ",
				npc_id,
				" | Servicio: ",
				service_id,
				" | Motivo: ",
				reason
			)

# =========================================================
# VAULT PERSISTENTE LISTA
# =========================================================

func apply_authoritative_vault_ready() -> bool:
	if account_state == null:
		return false


	if account_state.vault == null:
		return false


	if pending_authorized_service_id != "warehouse":
		return false


	if pending_authorized_npc_id.is_empty():
		return false


	# -----------------------------------------------------
	# AccountState sigue siendo el mismo objeto,
	# pero su propiedad `vault` fue reemplazada por el
	# InventoryData reconstruido desde Laravel.
	#
	# Volvemos a vincular para que VaultWindow deje de
	# apuntar al InventoryData anterior.
	# -----------------------------------------------------

	gameplay_ui.bind_account_state(
		account_state
	)


	if not gameplay_ui.open_authorized_vault():
		return false

	authorized_vault_active = true

	print(
		"GameplayScreen | Vault persistente aplicada",
		" | NPC: ",
		pending_authorized_npc_id,
		" | Items: ",
		account_state.vault.items.size()
	)


	pending_authorized_npc_id = ""
	pending_authorized_service_id = ""


	return true


func _on_vault_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	if not authorized_vault_active:
		return


	if uid.strip_edges().is_empty():
		return


	if current_position == new_position:
		return


	vault_item_move_requested.emit(
		uid,
		current_position,
		new_position
	)


# =========================================================
# REFRESCAR VAULT YA ABIERTA
# =========================================================

func refresh_authoritative_vault() -> bool:
	if not authorized_vault_active:
		return false


	if account_state == null:
		return false


	if account_state.vault == null:
		return false


	gameplay_ui.bind_account_state(
		account_state
	)


	print(
		"GameplayScreen | Vault persistente actualizada",
		" | Items: ",
		account_state.vault.items.size()
	)


	return true

# =========================================================
# ACTIVACIÓN DE ITEM AUTORITATIVO
# =========================================================

func _on_inventory_item_activation_requested(
	uid: String,
	item_id: String
) -> void:
	if player_state == null:
		return


	if player_state.inventory == null:
		return


	var normalized_uid := (
		uid
		.strip_edges()
		.to_lower()
	)


	var normalized_item_id := (
		item_id
		.strip_edges()
		.to_lower()
	)


	if normalized_uid.is_empty():
		return


	if normalized_item_id.is_empty():
		return


	# -----------------------------------------------------
	# ¿ES UN SKILL SCROLL?
	#
	# Items normales simplemente no tienen handler todavía.
	# -----------------------------------------------------

	var skill_id := (
		ClientSkillLearningCatalog.get_skill_id_for_scroll(
			normalized_item_id
		)
	)


	if skill_id.is_empty():
		return


	# -----------------------------------------------------
	# CONTRATO CLIENTE VÁLIDO
	#
	# Esto NO autoriza gameplay.
	# Sólo evita que un mapping local roto mande basura.
	# -----------------------------------------------------

	if ClientSkillCatalog.get_definition(
		skill_id
	) == null:
		push_warning(
			(
				"GameplayScreen | "
				+
				"Skill Scroll apunta a una Skill "
				+
				"desconocida por el catálogo cliente: %s"
			)
			%
			skill_id
		)


		return


	# -----------------------------------------------------
	# TRAINER
	#
	# UX gating basado exclusivamente en una autorización
	# previamente recibida del Game Server.
	#
	# Incluso después de pasar esto, el Server vuelve a
	# validar el servicio activo.
	# -----------------------------------------------------

	if not authorized_skill_trainer_active:
		print(
			"GameplayScreen | Aprendizaje omitido",
			" | Skill: ",
			skill_id,
			" | Scroll UID: ",
			normalized_uid,
			" | Reason: skill_trainer_required"
		)


		return


	if authorized_skill_trainer_npc_id.is_empty():
		return


	print(
		"GameplayScreen | Intención de aprendizaje",
		" | Skill: ",
		skill_id,
		" | Scroll: ",
		normalized_item_id,
		" | Scroll UID: ",
		normalized_uid,
		" | Trainer: ",
		authorized_skill_trainer_npc_id
	)


	skill_learning_intent_requested.emit(
		skill_id,
		normalized_uid
	)

# =========================================================
# INVENTORY AUTORITATIVO
# =========================================================

func apply_authoritative_inventory_snapshot(
	snapshot: Dictionary
) -> bool:
	if player_state == null:
		return false


	if not player_state.apply_inventory_snapshot(
		snapshot
	):
		return false


	gameplay_ui.refresh_inventory_state()


	print(
		"GameplayScreen | Inventory persistente actualizado",
		" | Items: ",
		player_state.inventory.items.size()
	)


	return true

# =========================================================
# EQUIPMENT AUTORITATIVO
# =========================================================

func apply_authoritative_equipment_snapshot(
	snapshot: Dictionary
) -> bool:
	if player_state == null:
		return false


	if not player_state.apply_equipment_snapshot(
		snapshot
	):
		return false


	if gameplay_ui == null:
		return false


	# -----------------------------------------------------
	# InventoryWindow consume InventoryData + EquipmentData.
	#
	# Como apply_equipment_snapshot reemplaza la instancia
	# completa de EquipmentData, debemos rebindeárselos.
	# -----------------------------------------------------

	gameplay_ui.refresh_inventory_state()


	print(
		"GameplayScreen | Equipment persistente actualizado",
		" | Items: ",
		player_state.equipment.get_equipped_items().size()
	)


	return true

# =========================================================
# MOVIMIENTO DE INVENTORY
# =========================================================

func _on_inventory_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	if player_state == null:
		return


	if player_state.inventory == null:
		return


	if uid.strip_edges().is_empty():
		return


	if current_position == new_position:
		return


	inventory_item_move_requested.emit(
		uid,
		current_position,
		new_position
	)

# =========================================================
# INVENTORY -> EQUIPMENT
# =========================================================

func _on_equipment_item_equip_requested(
	uid: String,
	current_position: Vector2i,
	target_slot_id: StringName
) -> void:
	if player_state == null:
		return


	if player_state.inventory == null:
		return


	if player_state.equipment == null:
		return


	var normalized_uid := (
		uid.strip_edges()
	)


	if normalized_uid.is_empty():
		return


	if not EquipmentSlotCatalog.is_valid_slot_id(
		target_slot_id
	):
		return


	equipment_item_equip_requested.emit(
		normalized_uid,
		current_position,
		target_slot_id
	)


# =========================================================
# EQUIPMENT -> INVENTORY
# =========================================================

func _on_equipment_item_unequip_requested(
	uid: String,
	source_slot_id: StringName,
	new_position: Vector2i
) -> void:
	if player_state == null:
		return


	if player_state.inventory == null:
		return


	if player_state.equipment == null:
		return


	var normalized_uid := (
		uid.strip_edges()
	)


	if normalized_uid.is_empty():
		return


	if not EquipmentSlotCatalog.is_valid_slot_id(
		source_slot_id
	):
		return


	equipment_item_unequip_requested.emit(
		normalized_uid,
		source_slot_id,
		new_position
	)

func _on_item_container_transfer_requested(
	uid: String,
	source_container: String,
	target_container: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	# -----------------------------------------------------
	# Si Vault no está realmente autorizada por Game Server
	# no existe una transferencia válida.
	# -----------------------------------------------------

	if not authorized_vault_active:
		return


	if uid.strip_edges().is_empty():
		return


	var valid_direction := (
		(
			source_container == "inventory"
			and
			target_container == "vault"
		)
		or
		(
			source_container == "vault"
			and
			target_container == "inventory"
		)
	)


	if not valid_direction:
		return


	item_container_transfer_requested.emit(
		uid,
		source_container,
		target_container,
		current_position,
		new_position
	)

# =========================================================
# RESULTADO AUTORITATIVO DE SKILL
# =========================================================

func apply_authoritative_skill_cast_result(
	request_id: int,
	accepted: bool,
	skill_id: String,
	reason: String,
	vitals_snapshot: Dictionary,
	cooldown_remaining_seconds: float,
	effect: Dictionary
) -> void:
	if player_state == null:
		return


	if not player_state.apply_vitals_snapshot(
		vitals_snapshot
	):
		world_load_failed.emit(
			"No se pudieron aplicar los vitals autoritativos del cast."
		)


		return

	if player_state.skill_cooldowns == null:
		push_warning(
			(
				"GameplayScreen | "
				+
				"No existe SkillCooldownState."
			)
		)


		return


	if not player_state.skill_cooldowns.sync_authoritative(
		skill_id,
		cooldown_remaining_seconds
	):
		push_warning(
			(
				"GameplayScreen | "
				+
				"No se pudo sincronizar el cooldown "
				+
				"autoritativo de '%s'."
			)
			%
			skill_id
		)


		return

	var effect_kind := String(
		effect.get(
			"kind",
			""
		)
	)


	var effect_amount := int(
		effect.get(
			"amount",
			0
		)
	)


	print(
		"GameplayScreen | Resultado autoritativo aplicado",
		" | Request: ",
		request_id,
		" | Skill: ",
		skill_id,
		" | Accepted: ",
		accepted,
		" | Reason: ",
		reason,
		" | Effect: ",
		effect_kind,
		" | Amount: ",
		effect_amount,
		" | Cooldown: ",
		cooldown_remaining_seconds,
		" | HP: ",
		player_state.vitals.hp,
		"/",
		player_state.vitals.max_hp,
		" | MP: ",
		player_state.vitals.mp,
		"/",
		player_state.vitals.max_mp
	)


# =========================================================
# SINCRONIZAR WORLD DROPS
# =========================================================

func sync_world_drops(
	drops: Array
) -> void:
	_clear_world_drops()


	for drop_value: Variant in drops:
		if typeof(drop_value) != TYPE_DICTIONARY:
			continue


		var drop: Dictionary = (
			drop_value
		)


		_spawn_or_update_world_drop(
			drop
		)


	print(
		"GameplayScreen | Drops sincronizados",
		" | Cantidad: ",
		world_drop_actors.size()
	)

func apply_world_drop_spawned(
	drop: Dictionary
) -> void:
	if drop.is_empty():
		return


	_spawn_or_update_world_drop(
		drop
	)

func _spawn_or_update_world_drop(
	drop: Dictionary
) -> void:
	if drops_root == null:
		return


	if player_state == null:
		return


	if player_state.world == null:
		return


	var entity_id := String(
		drop.get(
			"entity_id",
			""
		)
	).strip_edges().to_lower()


	if entity_id.is_empty():
		return


	var world_value: Variant = (
		drop.get(
			"world",
			null
		)
	)


	if typeof(world_value) != TYPE_DICTIONARY:
		return


	var world: Dictionary = (
		world_value
	)


	var drop_map_id := String(
		world.get(
			"map_id",
			""
		)
	).strip_edges()


	if (
		drop_map_id
		!=
		player_state.world.map_id
	):
		return


	if world_drop_actors.has(
		entity_id
	):
		var existing_value: Variant = (
			world_drop_actors[
				entity_id
			]
		)


		var existing_actor := (
			existing_value
			as WorldDropActor
		)


		if (
			existing_actor != null
			and
			is_instance_valid(
				existing_actor
			)
		):
			existing_actor.setup(
				drop
			)


		return


	var actor_instance := (
		WORLD_DROP_ACTOR_SCENE.instantiate()
	)


	if actor_instance == null:
		return


	var drop_actor := (
		actor_instance
		as WorldDropActor
	)


	if drop_actor == null:
		actor_instance.free()


		return


	drops_root.add_child(
		drop_actor
	)


	if not drop_actor.setup(
		drop
	):
		drop_actor.queue_free()


		return


	world_drop_actors[
		entity_id
	] = drop_actor

func _clear_world_drops() -> void:
	for actor_value: Variant in world_drop_actors.values():
		var drop_actor := (
			actor_value
			as WorldDropActor
		)


		if (
			drop_actor != null
			and
			is_instance_valid(
				drop_actor
			)
		):
			drop_actor.queue_free()


	world_drop_actors.clear()

func _on_world_drop_pickup_requested(
	entity_id: String
) -> void:
	var normalized_entity_id := (
		entity_id
		.strip_edges()
		.to_lower()
	)


	if normalized_entity_id.is_empty():
		return


	print(
		"GameplayScreen | Pickup solicitado",
		" | Entity: ",
		normalized_entity_id
	)


	world_drop_pickup_intent_requested.emit(
		normalized_entity_id
	)

func apply_world_drop_removed(
	entity_id: String
) -> void:
	var normalized_entity_id := (
		entity_id
		.strip_edges()
		.to_lower()
	)


	if not world_drop_actors.has(
		normalized_entity_id
	):
		return


	var actor_value: Variant = (
		world_drop_actors[
			normalized_entity_id
		]
	)


	world_drop_actors.erase(
		normalized_entity_id
	)


	var drop_actor := (
		actor_value
		as WorldDropActor
	)


	if (
		drop_actor != null
		and
		is_instance_valid(
			drop_actor
		)
	):
		drop_actor.queue_free()


	print(
		"GameplayScreen | World Drop eliminado",
		" | Entity: ",
		normalized_entity_id
	)

# =========================================================
# PROGRESIÓN AUTORITATIVA
# =========================================================

func apply_authoritative_progression_snapshot(
	snapshot: Dictionary
) -> bool:
	if player_state == null:
		return false


	if not player_state.apply_progression_snapshot(
		snapshot
	):
		return false


	_refresh_character_debug()


	if player_state.experience != null:
		print(
			"GameplayScreen | Progression actualizada",
			" | Level: ",
			player_state.character_summary.level,
			" | EXP: ",
			player_state.experience.experience,
			"/",
			player_state.experience.experience_required
		)


	return true
