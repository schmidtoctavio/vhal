@tool
class_name SkillSlot
extends Control


# =========================================================
# SEÑALES
# =========================================================

signal selection_requested(
	index: int
)

signal skill_assignment_requested(
	index: int,
	skill: SkillDefinition
)

# =========================================================
# HOTBAR
# =========================================================

@export_group("Hotbar")

@export_range(0, 2, 1)
var hotbar_index: int = 0:
	set(value):
		hotbar_index = clampi(
			value,
			0,
			2
		)

		_refresh_visuals()


# =========================================================
# SKILL
# =========================================================

@export_group("Skill")

@export var skill_definition: SkillDefinition:
	set(value):
		skill_definition = value

		_refresh_visuals()
		_refresh_availability()
		_refresh_tooltip()


# =========================================================
# ESTADO
# =========================================================

var _selected: bool = false

var _cooldown_remaining: float = 0.0

var _can_afford_mana: bool = true


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh_visuals()
	_refresh_availability()
	_refresh_selection()


	if Engine.is_editor_hint():
		return


	var skill_button := get_node_or_null(
		"IconMargin/SkillButton"
	) as SkillButton


	if skill_button:
		skill_button.setup(
			self
		)


		if not skill_button.pressed.is_connected(
			_on_skill_pressed
		):
			skill_button.pressed.connect(
				_on_skill_pressed
			)


	_set_cooldown_visual(
		0.0
	)


# =========================================================
# COOLDOWN
#
# Lo conservamos visualmente por ahora.
# Más adelante el cooldown será estado runtime compartido
# y no pertenecerá exclusivamente al nodo visual.
# =========================================================

func _process(
	delta: float
) -> void:
	if Engine.is_editor_hint():
		return


	if _cooldown_remaining <= 0.0:
		return


	_cooldown_remaining = maxf(
		_cooldown_remaining - delta,
		0.0
	)


	_set_cooldown_visual(
		_cooldown_remaining
	)


# =========================================================
# CLICK SOBRE SLOT
# =========================================================

func _on_skill_pressed() -> void:
	if skill_definition == null:
		return


	# IMPORTANTE:
	# ya NO ejecutamos la skill.
	#
	# Sólo solicitamos seleccionar esta posición
	# de la hotbar.
	selection_requested.emit(
		hotbar_index
	)


# =========================================================
# CONFIGURAR SKILL
# =========================================================

func set_skill(
	definition: SkillDefinition
) -> void:
	skill_definition = definition


func clear_skill() -> void:
	skill_definition = null


func has_skill() -> bool:
	return skill_definition != null


# =========================================================
# SELECCIÓN
# =========================================================

func set_selected(
	value: bool
) -> void:
	if _selected == value:
		return


	_selected = value

	_refresh_selection()


func is_selected() -> bool:
	return _selected


func _refresh_selection() -> void:
	var skill_button := get_node_or_null(
		"IconMargin/SkillButton"
	) as TextureButton


	var hotkey_label := get_node_or_null(
		"HotkeyLabel"
	) as Label


	# -----------------------------------------------------
	# FEEDBACK TEMPORAL
	#
	# Después usaremos una textura específica de selección.
	#
	# Por ahora:
	#
	# seleccionado     = brillo normal
	# no seleccionado = ligeramente oscurecido
	# -----------------------------------------------------

	var brightness := 1.0


	if not _selected:
		brightness = 0.72


	if skill_definition == null:
		brightness = 0.45


	var visual_color := Color(
		brightness,
		brightness,
		brightness,
		1.0
	)


	if skill_button:
		skill_button.modulate = (
			visual_color
		)


	if hotkey_label:
		hotkey_label.modulate = (
			visual_color
		)


# =========================================================
# INFORMACIÓN DERIVADA DE SKILL DEFINITION
# =========================================================

func get_mana_cost() -> int:
	if skill_definition == null:
		return 0


	return skill_definition.mana_cost


func get_cooldown_duration() -> float:
	if skill_definition == null:
		return 0.0


	return skill_definition.cooldown_duration


# =========================================================
# COOLDOWN
# =========================================================

func start_cooldown() -> void:
	if skill_definition == null:
		return


	if _cooldown_remaining > 0.0:
		return


	_cooldown_remaining = (
		get_cooldown_duration()
	)


	_set_cooldown_visual(
		_cooldown_remaining
	)


func is_on_cooldown() -> bool:
	return (
		_cooldown_remaining > 0.0
	)


# =========================================================
# DISPONIBILIDAD / MANA
# =========================================================

func set_can_afford_mana(
	can_afford: bool
) -> void:
	_can_afford_mana = (
		can_afford
	)

	_refresh_availability()


func can_afford_mana() -> bool:
	return _can_afford_mana


func _refresh_availability() -> void:
	var unavailable_overlay := get_node_or_null(
		"IconMargin/UnavailableOverlay"
	) as ColorRect


	if unavailable_overlay:
		unavailable_overlay.visible = (
			skill_definition != null
			and
			not _can_afford_mana
		)


# =========================================================
# VISUAL GENERAL
# =========================================================

func _refresh_visuals() -> void:
	var skill_button := get_node_or_null(
		"IconMargin/SkillButton"
	) as TextureButton


	var cooldown_overlay := get_node_or_null(
		"IconMargin/CooldownOverlay"
	) as TextureProgressBar


	var hotkey_label := get_node_or_null(
		"HotkeyLabel"
	) as Label


	var cooldown_label := get_node_or_null(
		"CooldownLabel"
	) as Label


	# -----------------------------------------------------
	# ICONO
	# -----------------------------------------------------

	var skill_icon: Texture2D = null


	if skill_definition != null:
		skill_icon = (
			skill_definition.icon
		)


	if skill_button:
		skill_button.texture_normal = (
			skill_icon
		)


	if cooldown_overlay:
		cooldown_overlay.texture_progress = (
			skill_icon
		)


		if Engine.is_editor_hint():
			cooldown_overlay.visible = false


	# -----------------------------------------------------
	# HOTKEY
	#
	# índice 0 → "1"
	# índice 1 → "2"
	# índice 2 → "3"
	# -----------------------------------------------------

	if hotkey_label:
		hotkey_label.text = str(
			hotbar_index + 1
		)


	if cooldown_label and Engine.is_editor_hint():
		cooldown_label.visible = false


	_refresh_availability()
	_refresh_selection()
	_refresh_tooltip()


# =========================================================
# TOOLTIP
# =========================================================

func _refresh_tooltip() -> void:
	if Engine.is_editor_hint():
		return


	var skill_button := get_node_or_null(
		"IconMargin/SkillButton"
	) as SkillButton


	if skill_button:
		skill_button.setup(
			self
		)


# =========================================================
# COOLDOWN VISUAL
# =========================================================

func _set_cooldown_visual(
	seconds: float
) -> void:
	var cooldown_overlay := get_node_or_null(
		"IconMargin/CooldownOverlay"
	) as TextureProgressBar


	var cooldown_label := get_node_or_null(
		"CooldownLabel"
	) as Label


	var is_active := (
		seconds > 0.0
	)


	if cooldown_overlay:
		cooldown_overlay.min_value = 0.0

		cooldown_overlay.max_value = maxf(
			get_cooldown_duration(),
			0.001
		)

		cooldown_overlay.value = seconds

		cooldown_overlay.visible = (
			is_active
		)


	if cooldown_label:
		cooldown_label.visible = (
			is_active
		)


		if is_active:
			cooldown_label.text = (
				"%.1f" % seconds
			)

		else:
			cooldown_label.text = ""

# =========================================================
# DRAG & DROP - SOLICITAR ASIGNACIÓN
# =========================================================

func request_skill_assignment(
	skill: SkillDefinition
) -> void:
	if skill == null:
		return


	skill_assignment_requested.emit(
		hotbar_index,
		skill
	)
