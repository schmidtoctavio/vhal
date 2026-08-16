class_name GameplayUI
extends Control


# =========================================================
# BARRAS
# =========================================================

@onready var hp_bar: StatBar = (
	$BottomHUD/HPBar
)

@onready var mp_bar: StatBar = (
	$BottomHUD/MPBar
)


# =========================================================
# ESTADO DEL JUGADOR
# =========================================================

var player_state: PlayerRuntimeState = null


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

@onready var vault_window: BaseWindow = (
	$WindowsLayer/VaultWindow
)


# =========================================================
# SKILLS WINDOW
# =========================================================

@onready var skills_window: SkillsWindow = (
	$WindowsLayer/SkillsWindow
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


func _activate_player_state() -> void:
	if player_state == null:
		return


	_activate_vitals_state()

	_activate_skill_state()

	_activate_inventory_state()


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
# SKILL STATE
# =========================================================

func _activate_skill_state() -> void:
	skill_book_data = (
		player_state.skill_book
	)

	skill_hotbar_data = (
		player_state.skill_hotbar
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
	if player_state == null:
		return


	inventory_window.bind_models(
		player_state.inventory,
		player_state.equipment
	)

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


	# =====================================================
	# VAULT
	# =====================================================

	if not vault_button.pressed.is_connected(
		_on_vault_button_pressed
	):
		vault_button.pressed.connect(
			_on_vault_button_pressed
		)


	if not vault_window.close_requested.is_connected(
		_on_vault_close_requested
	):
		vault_window.close_requested.connect(
			_on_vault_close_requested
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
	# PLAYER STATE
	# =====================================================

	if player_state != null:
		_activate_player_state()


func _exit_tree() -> void:
	_disconnect_player_state()


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
	# DEBUG DAMAGE
	# =====================================================

	if InputMap.has_action(
		&"debug_damage"
	):
		if event.is_action_pressed(
			&"debug_damage"
		):
			if (
				player_state != null
				and
				player_state.vitals != null
			):
				player_state.vitals.set_hp(
					player_state.vitals.hp
					-
					350
				)


	# =====================================================
	# DEBUG HEAL
	# =====================================================

	if InputMap.has_action(
		&"debug_heal"
	):
		if event.is_action_pressed(
			&"debug_heal"
		):
			if (
				player_state != null
				and
				player_state.vitals != null
			):
				player_state.vitals.set_hp(
					player_state.vitals.hp
					+
					350
				)


	# =====================================================
	# DEBUG RESTORE MANA
	# =====================================================

	if InputMap.has_action(
		&"debug_restore_mana"
	):
		if event.is_action_pressed(
			&"debug_restore_mana"
		):
			if (
				player_state != null
				and
				player_state.vitals != null
			):
				player_state.vitals.set_mp(
					player_state.vitals.max_mp
				)


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
# VAULT
# =========================================================

func _on_vault_button_pressed() -> void:
	_toggle_vault()


func _on_vault_close_requested() -> void:
	_close_vault()


func _toggle_vault() -> void:
	vault_window.visible = (
		not vault_window.visible
	)


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
