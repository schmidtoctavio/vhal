class_name GameplayUI
extends Control


# =========================================================
# SEÑALES
# =========================================================

signal authorized_vault_closed

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

signal inventory_item_activation_requested(
	uid: String,
	item_id: String
)

signal authorized_skill_trainer_closed

signal skill_trainer_learn_requested(
	skill_id: String,
	scroll_uid: String
)

# =========================================================
# BARRAS
# =========================================================

@onready var hp_bar: StatBar = (
	$BottomHUD/HPBar
)

@onready var mp_bar: StatBar = (
	$BottomHUD/MPBar
)

@onready var xp_bar: StatBar = (
	$BottomHUD/XPBar
)

# =========================================================
# ESTADO DEL JUGADOR
# =========================================================

var player_state: PlayerRuntimeState = null

var account_state: AccountState = null

# =========================================================
# SKILLS / HOTBAR
# =========================================================

@onready var skills_container: HBoxContainer = (
	$BottomHUD/SkillsArea/HBoxContainer
)

@onready var selected_skill_slot: SelectedSkillSlot = (
	$BottomHUD/SelectedSkillSlot
)


var skill_hotbar_data: SkillHotbarData = null

var skill_book_data: SkillBookData = null

var skill_cooldown_state: SkillCooldownState = null

# =========================================================
# PERSONAJE / PRIMARY STATS
# =========================================================

@onready var character_button: HudActionButton = (
	$BottomHUD/HudActionsArea/ButtonsRow/CharacterButton
)

@onready var character_stats_window: CharacterStatsWindow = (
	$WindowsLayer/CharacterStatsWindow
)



# =========================================================
# INVENTARIO
# =========================================================

@onready var inventory_button: HudActionButton = (
	$BottomHUD/HudActionsArea/ButtonsRow/InventoryButton
)

@onready var inventory_window: InventoryWindow = (
	$WindowsLayer/InventoryWindow
)


# =========================================================
# VAULT
# =========================================================

@onready var vault_button: HudActionButton = (
	$BottomHUD/HudActionsArea/ButtonsRow/VaultButton
)

@onready var vault_window: VaultWindow = (
	$WindowsLayer/VaultWindow
)


# =========================================================
# SKILLS WINDOW
# =========================================================

@onready var skills_window: SkillsWindow = (
	$WindowsLayer/SkillsWindow
)

# =========================================================
# SKILL TRAINER WINDOW
# =========================================================

@onready var skill_trainer_window: SkillTrainerWindow = (
	$WindowsLayer/SkillTrainerWindow
)

# =========================================================
# PLAYER STATE
# =========================================================

func bind_player_state(
	state: PlayerRuntimeState
) -> void:
	if player_state == state:
		if is_node_ready():
			_activate_player_state()

		return


	_disconnect_player_state()


	player_state = state


	if is_node_ready():
		_activate_player_state()

# =========================================================
# ACCOUNT STATE
# =========================================================

func bind_account_state(
	state: AccountState
) -> void:
	account_state = state


	if is_node_ready():
		_activate_account_state()


func _activate_account_state() -> void:
	if account_state == null:
		vault_window.bind_vault_data(
			null
		)

		return


	vault_window.bind_vault_data(
		account_state.vault
	)

func _activate_player_state() -> void:
	if player_state == null:
		return


	_activate_vitals_state()

	_activate_experience_state()

	_activate_primary_stats_state()

	_activate_skill_state()

	_activate_inventory_state()

# =========================================================
# PRIMARY STATS STATE
# =========================================================

func _activate_primary_stats_state() -> void:
	if player_state == null:
		character_stats_window.bind_primary_stats(
			null
		)


		return


	character_stats_window.bind_primary_stats(
		player_state.primary_stats
	)



# =========================================================
# VITALS STATE
# =========================================================

func _activate_vitals_state() -> void:
	if player_state.vitals == null:
		return


	if not player_state.vitals.hp_changed.is_connected(
		_on_vitals_hp_changed
	):
		player_state.vitals.hp_changed.connect(
			_on_vitals_hp_changed
		)


	if not player_state.vitals.mp_changed.is_connected(
		_on_vitals_mp_changed
	):
		player_state.vitals.mp_changed.connect(
			_on_vitals_mp_changed
		)


	_refresh_vitals_from_state(
		false
	)

# =========================================================
# EXPERIENCE STATE
# =========================================================

func _activate_experience_state() -> void:
	if player_state == null:
		return


	if player_state.experience == null:
		return


	if not player_state.experience.experience_changed.is_connected(
		_on_experience_changed
	):
		player_state.experience.experience_changed.connect(
			_on_experience_changed
		)


	_refresh_experience_from_state(
		false
	)


func _refresh_experience_from_state(
	animated: bool = false
) -> void:
	if player_state == null:
		return


	if player_state.experience == null:
		return


	xp_bar.set_values(
		float(
			player_state.experience.experience
		),
		float(
			player_state.experience.experience_required
		),
		animated
	)


func _on_experience_changed(
	current: int,
	required: int
) -> void:
	xp_bar.set_values(
		float(current),
		float(required),
		true
	)

# =========================================================
# SKILL STATE
# =========================================================

func _activate_skill_state() -> void:
	skill_book_data = (
		player_state.skill_book
	)

	skill_hotbar_data = (
		player_state.skill_hotbar
	)

	skill_cooldown_state = (
		player_state.skill_cooldowns
	)

	# -----------------------------------------------------
	# SKILL BOOK
	# -----------------------------------------------------

	skills_window.bind_skill_book(
		skill_book_data
	)


	# -----------------------------------------------------
	# HOTBAR
	# -----------------------------------------------------

	if skill_hotbar_data == null:
		return


	if not skill_hotbar_data.slot_changed.is_connected(
		_on_hotbar_slot_changed
	):
		skill_hotbar_data.slot_changed.connect(
			_on_hotbar_slot_changed
		)


	if not skill_hotbar_data.selection_changed.is_connected(
		_on_hotbar_selection_changed
	):
		skill_hotbar_data.selection_changed.connect(
			_on_hotbar_selection_changed
		)


	# -----------------------------------------------------
	# Vincular los slots visuales con el modelo.
	# -----------------------------------------------------

	_bind_hotbar_slots()


	# -----------------------------------------------------
	# Restaurar selección actual.
	# -----------------------------------------------------

	_on_hotbar_selection_changed(
		skill_hotbar_data.selected_index,
		skill_hotbar_data.get_selected_skill()
	)


	# -----------------------------------------------------
	# Actualizar disponibilidad según mana.
	# -----------------------------------------------------

	_refresh_skill_mana_states(
		mp_bar.current_value
	)

# =========================================================
# INVENTORY / EQUIPMENT STATE
# =========================================================

func _activate_inventory_state() -> void:
	inventory_window.set_authoritative_inventory_mode(
		true
	)


	if player_state == null:
		return


	inventory_window.bind_models(
		player_state.inventory,
		player_state.equipment
	)
# =========================================================
# REFRESCAR INVENTORY AUTORITATIVO
# =========================================================

func refresh_inventory_state() -> void:
	if player_state == null:
		return


	_activate_inventory_state()

# =========================================================
# DESCONECTAR PLAYER STATE
# =========================================================

func _disconnect_player_state() -> void:
	# -----------------------------------------------------
	# VITALS
	# -----------------------------------------------------

	if (
		player_state != null
		and
		player_state.vitals != null
	):
		if player_state.vitals.hp_changed.is_connected(
			_on_vitals_hp_changed
		):
			player_state.vitals.hp_changed.disconnect(
				_on_vitals_hp_changed
			)


		if player_state.vitals.mp_changed.is_connected(
			_on_vitals_mp_changed
		):
			player_state.vitals.mp_changed.disconnect(
				_on_vitals_mp_changed
			)

	# -----------------------------------------------------
	# EXPERIENCE
	# -----------------------------------------------------

	if (
		player_state != null
		and
		player_state.experience != null
	):
		if player_state.experience.experience_changed.is_connected(
			_on_experience_changed
		):
			player_state.experience.experience_changed.disconnect(
				_on_experience_changed
			)

	# -----------------------------------------------------
	# HOTBAR
	# -----------------------------------------------------

	if skill_hotbar_data != null:
		if skill_hotbar_data.slot_changed.is_connected(
			_on_hotbar_slot_changed
		):
			skill_hotbar_data.slot_changed.disconnect(
				_on_hotbar_slot_changed
			)


		if skill_hotbar_data.selection_changed.is_connected(
			_on_hotbar_selection_changed
		):
			skill_hotbar_data.selection_changed.disconnect(
				_on_hotbar_selection_changed
			)

	# -----------------------------------------------------
	# PRIMARY STATS
	# -----------------------------------------------------

	if is_node_ready():
		character_stats_window.bind_primary_stats(
			null
		)



	# -----------------------------------------------------
	# SKILL BOOK
	#
	# SkillsWindow administra la conexión con SkillBookData.
	# -----------------------------------------------------

	if is_node_ready():
		skills_window.bind_skill_book(
			null
		)

	# -----------------------------------------------------
	# INVENTORY / EQUIPMENT
	# -----------------------------------------------------

	if is_node_ready():
		inventory_window.bind_models(
			null,
			null
		)

	skill_hotbar_data = null

	skill_book_data = null

	skill_cooldown_state = null

# =========================================================
# REFRESCAR VITALES
# =========================================================

func _refresh_vitals_from_state(
	animated: bool = false
) -> void:
	if player_state == null:
		return


	if player_state.vitals == null:
		return


	hp_bar.set_values(
		float(player_state.vitals.hp),
		float(player_state.vitals.max_hp),
		animated
	)


	mp_bar.set_values(
		float(player_state.vitals.mp),
		float(player_state.vitals.max_mp),
		animated
	)


func _on_vitals_hp_changed(
	current: int,
	maximum: int
) -> void:
	hp_bar.set_values(
		float(current),
		float(maximum),
		true
	)


func _on_vitals_mp_changed(
	current: int,
	maximum: int
) -> void:
	mp_bar.set_values(
		float(current),
		float(maximum),
		true
	)


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# =====================================================
	# MANA
	# =====================================================

	if not mp_bar.value_changed.is_connected(
		_on_mana_changed
	):
		mp_bar.value_changed.connect(
			_on_mana_changed
		)

	# =====================================================
	# PERSONAJE / PRIMARY STATS
	# =====================================================

	if not character_button.pressed.is_connected(
		_on_character_button_pressed
	):
		character_button.pressed.connect(
			_on_character_button_pressed
		)


	if not character_stats_window.close_requested.is_connected(
		_on_character_window_close_requested
	):
		character_stats_window.close_requested.connect(
			_on_character_window_close_requested
		)



	# =====================================================
	# INVENTARIO
	# =====================================================

	if not inventory_button.pressed.is_connected(
		_on_inventory_button_pressed
	):
		inventory_button.pressed.connect(
			_on_inventory_button_pressed
		)


	if not inventory_window.close_requested.is_connected(
		_on_inventory_close_requested
	):
		inventory_window.close_requested.connect(
			_on_inventory_close_requested
		)

	if not inventory_window.inventory_item_move_requested.is_connected(
		_on_inventory_item_move_requested
	):
		inventory_window.inventory_item_move_requested.connect(
			_on_inventory_item_move_requested
		)

	if not inventory_window.inventory_item_activation_requested.is_connected(
		_on_inventory_item_activation_requested
	):
		inventory_window.inventory_item_activation_requested.connect(
			_on_inventory_item_activation_requested
		)

	if not inventory_window.item_container_transfer_requested.is_connected(
		_on_item_container_transfer_requested
	):
		inventory_window.item_container_transfer_requested.connect(
			_on_item_container_transfer_requested
		)

	if not inventory_window.equipment_item_equip_requested.is_connected(
		_on_equipment_item_equip_requested
	):
		inventory_window.equipment_item_equip_requested.connect(
			_on_equipment_item_equip_requested
		)


	if not inventory_window.equipment_item_unequip_requested.is_connected(
		_on_equipment_item_unequip_requested
	):
		inventory_window.equipment_item_unequip_requested.connect(
			_on_equipment_item_unequip_requested
		)

	# =====================================================
	# VAULT
	# =====================================================
	#
	# La bóveda ya no puede abrirse directamente desde HUD.
	# Sólo se abre mediante una autorización del Game Server.
	# =====================================================

	vault_button.visible = false

	vault_window.visible = false


	if not vault_window.close_requested.is_connected(
		_on_vault_close_requested
	):
		vault_window.close_requested.connect(
			_on_vault_close_requested
		)

	if not vault_window.vault_item_move_requested.is_connected(
		_on_vault_item_move_requested
	):
		vault_window.vault_item_move_requested.connect(
			_on_vault_item_move_requested
		)

	if not vault_window.item_container_transfer_requested.is_connected(
		_on_item_container_transfer_requested
	):
		vault_window.item_container_transfer_requested.connect(
			_on_item_container_transfer_requested
		)

	# =====================================================
	# SELECTED SKILL SLOT
	# =====================================================

	if not selected_skill_slot.skills_panel_requested.is_connected(
		_on_skills_panel_requested
	):
		selected_skill_slot.skills_panel_requested.connect(
			_on_skills_panel_requested
		)


	# =====================================================
	# SKILLS WINDOW
	# =====================================================

	if not skills_window.close_requested.is_connected(
		_on_skills_window_close_requested
	):
		skills_window.close_requested.connect(
			_on_skills_window_close_requested
		)

	# =====================================================
	# SKILL TRAINER WINDOW
	# =====================================================

	skill_trainer_window.visible = false


	if not skill_trainer_window.close_requested.is_connected(
		_on_skill_trainer_close_requested
	):
		skill_trainer_window.close_requested.connect(
			_on_skill_trainer_close_requested
		)

	if not skill_trainer_window.learn_requested.is_connected(
		_on_skill_trainer_learn_requested
	):
		skill_trainer_window.learn_requested.connect(
			_on_skill_trainer_learn_requested
		)

	# =====================================================
	# PLAYER STATE
	# =====================================================

	if player_state != null:
		_activate_player_state()


func _exit_tree() -> void:
	_disconnect_player_state()

	vault_window.bind_vault_data(
		null
	)


# =========================================================
# HOTBAR - VINCULAR SLOTS VISUALES
# =========================================================

func _bind_hotbar_slots() -> void:
	var index := 0


	for child in skills_container.get_children():

		if not (
			child is SkillSlot
		):
			continue


		if index >= SkillHotbarData.SLOT_COUNT:
			break


		var slot := (
			child as SkillSlot
		)


		# -------------------------------------------------
		# SkillSlot  → hotbar 0 → tecla 1
		# SkillSlot2 → hotbar 1 → tecla 2
		# SkillSlot3 → hotbar 2 → tecla 3
		# -------------------------------------------------

		slot.hotbar_index = index


		# -------------------------------------------------
		# El contenido viene ahora del PlayerRuntimeState.
		# -------------------------------------------------

		slot.set_skill(
			skill_hotbar_data.get_skill(
				index
			)
		)


		# -------------------------------------------------
		# CLICK IZQUIERDO
		# → selecciona esta hotbar.
		# -------------------------------------------------

		if not slot.selection_requested.is_connected(
			_on_skill_slot_selection_requested
		):
			slot.selection_requested.connect(
				_on_skill_slot_selection_requested
			)


		# -------------------------------------------------
		# DRAG & DROP DESDE SKILL BOOK
		# → solicita asignar una skill a este hotbar.
		# -------------------------------------------------

		if not slot.skill_assignment_requested.is_connected(
			_on_skill_slot_assignment_requested
		):
			slot.skill_assignment_requested.connect(
				_on_skill_slot_assignment_requested
			)


		index += 1


# =========================================================
# HOTBAR - CLICK EN SLOT
# =========================================================

func _on_skill_slot_selection_requested(
	index: int
) -> void:
	if skill_hotbar_data == null:
		return


	skill_hotbar_data.select_slot(
		index
	)


# =========================================================
# HOTBAR - DROP DE SKILL
# =========================================================

func _on_skill_slot_assignment_requested(
	index: int,
	skill: SkillDefinition
) -> void:
	if skill_hotbar_data == null:
		return


	if skill == null:
		return


	skill_hotbar_data.set_skill(
		index,
		skill
	)


# =========================================================
# HOTBAR - TECLADO
# =========================================================

func _select_hotbar_skill(
	index: int
) -> void:
	if skill_hotbar_data == null:
		return


	skill_hotbar_data.select_slot(
		index
	)


# =========================================================
# HOTBAR - CAMBIÓ CONTENIDO
# =========================================================

func _on_hotbar_slot_changed(
	index: int,
	skill: SkillDefinition
) -> void:
	var slot := (
		_get_hotbar_slot(
			index
		)
	)


	if slot == null:
		return


	slot.set_skill(
		skill
	)


	# -----------------------------------------------------
	# Puede haber cambiado el coste de mana.
	# -----------------------------------------------------

	_refresh_skill_mana_states(
		mp_bar.current_value
	)


# =========================================================
# HOTBAR - CAMBIÓ SELECCIÓN
# =========================================================

func _on_hotbar_selection_changed(
	index: int,
	skill: SkillDefinition
) -> void:

	# =====================================================
	# SLOT GRANDE
	# =====================================================

	selected_skill_slot.set_skill(
		skill
	)


	# =====================================================
	# ESTADO VISUAL 1 / 2 / 3
	# =====================================================

	for child in skills_container.get_children():

		if not (
			child is SkillSlot
		):
			continue


		var slot := (
			child as SkillSlot
		)


		slot.set_selected(
			slot.hotbar_index == index
		)


	# =====================================================
	# DEBUG
	# =====================================================

	if skill == null:
		print(
			"Hotbar seleccionada: ",
			index + 1,
			" | VACÍA"
		)

		return


	print(
		"Hotbar seleccionada: ",
		index + 1,
		" | ",
		skill.display_name
	)


# =========================================================
# HOTBAR - OBTENER SLOT VISUAL
# =========================================================

func _get_hotbar_slot(
	index: int
) -> SkillSlot:
	var current_index := 0


	for child in skills_container.get_children():

		if not (
			child is SkillSlot
		):
			continue


		if current_index == index:
			return (
				child as SkillSlot
			)


		current_index += 1


	return null


# =========================================================
# MANA
# =========================================================

func _on_mana_changed(
	current: float,
	_maximum: float
) -> void:
	_refresh_skill_mana_states(
		current
	)


func _refresh_skill_mana_states(
	current_mana: float
) -> void:

	for child in skills_container.get_children():

		if not (
			child is SkillSlot
		):
			continue


		var slot := (
			child as SkillSlot
		)


		# -------------------------------------------------
		# SLOT VACÍO
		# -------------------------------------------------

		if not slot.has_skill():

			slot.set_can_afford_mana(
				true
			)

			continue


		# -------------------------------------------------
		# SLOT CON SKILL
		# -------------------------------------------------

		var can_afford := (
			current_mana
			>=
			float(
				slot.get_mana_cost()
			)
		)


		slot.set_can_afford_mana(
			can_afford
		)


# =========================================================
# INPUT
# =========================================================

func _unhandled_input(
	event: InputEvent
) -> void:

	# =====================================================
	# SKILL 1
	# =====================================================

	if event.is_action_pressed(
		&"select_skill_1"
	):
		_select_hotbar_skill(
			0
		)


	# =====================================================
	# SKILL 2
	# =====================================================

	if event.is_action_pressed(
		&"select_skill_2"
	):
		_select_hotbar_skill(
			1
		)


	# =====================================================
	# SKILL 3
	# =====================================================

	if event.is_action_pressed(
		&"select_skill_3"
	):
		_select_hotbar_skill(
			2
		)


	# =====================================================
	# INVENTARIO
	# =====================================================

	if event.is_action_pressed(
		&"toggle_inventory"
	):
		_toggle_inventory()

	# =====================================================
	# PERSONAJE / PRIMARY STATS
	# =====================================================

	if event.is_action_pressed(
		&"toggle_character"
	):
		_toggle_character_window()

	# =====================================================
	# SKILLS
	# =====================================================

	if event.is_action_pressed(
		&"toggle_skills"
	):
		_toggle_skills_window()

# =========================================================
# PERSONAJE / PRIMARY STATS
# =========================================================

func _on_character_button_pressed() -> void:
	_toggle_character_window()


func _on_character_window_close_requested() -> void:
	_close_character_window()


func _toggle_character_window() -> void:
	character_stats_window.visible = (
		not character_stats_window.visible
	)


func _close_character_window() -> void:
	character_stats_window.visible = false



# =========================================================
# INVENTARIO
# =========================================================

func _on_inventory_button_pressed() -> void:
	_toggle_inventory()


func _on_inventory_close_requested() -> void:
	_close_inventory()


func _toggle_inventory() -> void:
	inventory_window.visible = (
		not inventory_window.visible
	)


func _close_inventory() -> void:
	inventory_window.visible = false


# =========================================================
# SKILL TRAINER
# =========================================================

func open_authorized_skill_trainer(
	snapshot: Dictionary
) -> bool:
	var was_visible := (
		skill_trainer_window.visible
	)


	if not skill_trainer_window.apply_authoritative_snapshot(
		snapshot
	):
		return false


	skill_trainer_window.visible = true


	if not was_visible:
		skill_trainer_window.center_in_viewport()


	if was_visible:
		print(
			"GameplayUI | "
			+
			"Skill Trainer actualizado con ofertas autoritativas."
		)
	else:
		print(
			"GameplayUI | "
			+
			"Skill Trainer abierto con ofertas autoritativas."
		)


	return true


func _on_skill_trainer_close_requested() -> void:
	_close_skill_trainer()


	authorized_skill_trainer_closed.emit()


func _close_skill_trainer() -> void:
	skill_trainer_window.visible = false

	skill_trainer_window.clear_authoritative_snapshot()


func close_authorized_skill_trainer() -> void:
	_close_skill_trainer()


	print(
		"GameplayUI | Skill Trainer cerrado por Game Server."
	)

func _on_skill_trainer_learn_requested(
	skill_id: String,
	scroll_uid: String
) -> void:
	skill_trainer_learn_requested.emit(
		skill_id,
		scroll_uid
	)

# =========================================================
# VAULT
# =========================================================

func open_authorized_vault() -> bool:
	if account_state == null:
		return false


	if account_state.vault == null:
		return false


	vault_window.visible = true


	print(
		"GameplayUI | Vault abierta por servicio autorizado."
	)


	return true


func _on_vault_close_requested() -> void:
	_close_vault()


	authorized_vault_closed.emit()


func _close_vault() -> void:
	vault_window.visible = false

# =========================================================
# SKILLS WINDOW
# =========================================================

func _on_skills_panel_requested() -> void:
	_toggle_skills_window()


func _on_skills_window_close_requested() -> void:
	_close_skills_window()


func _toggle_skills_window() -> void:
	skills_window.visible = (
		not skills_window.visible
	)


func _close_skills_window() -> void:
	skills_window.visible = false

func close_authorized_vault() -> void:
	_close_vault()


	print(
		"GameplayUI | Vault cerrada por Game Server."
	)

func _on_vault_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	vault_item_move_requested.emit(
		uid,
		current_position,
		new_position
	)

func _on_inventory_item_activation_requested(
	uid: String,
	item_id: String
) -> void:
	inventory_item_activation_requested.emit(
		uid,
		item_id
	)

# =========================================================
# MOVIMIENTO DE INVENTORY
# =========================================================

func _on_inventory_item_move_requested(
	uid: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	inventory_item_move_requested.emit(
		uid,
		current_position,
		new_position
	)

func _on_item_container_transfer_requested(
	uid: String,
	source_container: String,
	target_container: String,
	current_position: Vector2i,
	new_position: Vector2i
) -> void:
	item_container_transfer_requested.emit(
		uid,
		source_container,
		target_container,
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
	equipment_item_equip_requested.emit(
		uid,
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
	equipment_item_unequip_requested.emit(
		uid,
		source_slot_id,
		new_position
	)

# =========================================================
# COOLDOWNS VISUALES
# =========================================================

func _refresh_skill_cooldown_visuals() -> void:
	if skills_container == null:
		return


	for child in skills_container.get_children():
		var slot := (
			child
			as SkillSlot
		)


		if slot == null:
			continue


		var skill := (
			slot.skill_definition
		)


		if (
			skill == null
			or
			skill_cooldown_state == null
		):
			slot.set_cooldown_remaining(
				0.0
			)


			continue


		var skill_id := String(
			skill.skill_id
		).strip_edges().to_lower()


		if skill_id.is_empty():
			slot.set_cooldown_remaining(
				0.0
			)


			continue


		var remaining := (
			skill_cooldown_state
			.get_remaining_seconds(
				skill_id
			)
		)


		slot.set_cooldown_remaining(
			remaining
		)

func _process(
	_delta: float
) -> void:
	if skill_cooldown_state == null:
		return


	_refresh_skill_cooldown_visuals()
