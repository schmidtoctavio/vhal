@tool
class_name StatBar
extends Control


signal value_changed(
	current: float,
	maximum: float
)


enum TextMode {
	HIDDEN,
	CURRENT_MAX,
	PERCENT,
	CURRENT_MAX_PERCENT
}


# =========================================================
# ESTADO INTERNO
# =========================================================

var _max_value: float = 100.0

var _current_value: float = 100.0


var _value_tween: Tween

var _ghost_tween: Tween


# =========================================================
# TEXTURAS
# =========================================================

@export_group("Textures")


@export var under_texture: Texture2D:
	set(value):
		under_texture = value
		_refresh_visuals()


@export var progress_texture: Texture2D:
	set(value):
		progress_texture = value
		_refresh_visuals()


@export var over_texture: Texture2D:
	set(value):
		over_texture = value
		_refresh_visuals()


# =========================================================
# VALORES
# =========================================================

@export_group("Values")


@export var max_value: float = 100.0:
	get:
		return _max_value

	set(value):
		_max_value = maxf(
			value,
			1.0
		)

		_current_value = clampf(
			_current_value,
			0.0,
			_max_value
		)

		_refresh_values_instant()

		if not Engine.is_editor_hint():
			_notify_value_changed()


@export var current_value: float = 100.0:
	get:
		return _current_value

	set(value):
		_current_value = clampf(
			value,
			0.0,
			_max_value
		)

		_refresh_values_instant()

		if not Engine.is_editor_hint():
			_notify_value_changed()


# =========================================================
# TEXTO
# =========================================================

@export_group("Text")


@export var text_mode: TextMode = TextMode.CURRENT_MAX:
	set(value):
		text_mode = value
		_refresh_values_instant()


# =========================================================
# ANIMACIÓN PRINCIPAL
# =========================================================

@export_group("Animation")


@export var smooth_change: bool = true


@export_range(0.01, 2.0, 0.01)
var smooth_duration: float = 0.20


# =========================================================
# GHOST BAR
# =========================================================

@export_group("Ghost Bar")


@export var ghost_enabled: bool = true:
	set(value):
		ghost_enabled = value
		_refresh_visuals()


@export_range(0.0, 1.0, 0.01)
var ghost_delay: float = 0.18


@export_range(0.01, 2.0, 0.01)
var ghost_duration: float = 0.45


@export var ghost_tint: Color = Color(
	1.0,
	1.0,
	1.0,
	0.55
):
	set(value):
		ghost_tint = value
		_refresh_visuals()


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh_visuals()
	_refresh_values_instant()


# =========================================================
# API PÚBLICA
# =========================================================

func set_values(
	current: float,
	maximum: float,
	animated: bool = true
) -> void:
	var previous_value := _current_value

	_max_value = maxf(
		maximum,
		1.0
	)

	_current_value = clampf(
		current,
		0.0,
		_max_value
	)

	_notify_value_changed()

	_update_range()

	if animated:
		_animate_change(
			previous_value,
			_current_value
		)
	else:
		_refresh_values_instant()


func set_current_value(
	new_value: float,
	animated: bool = true
) -> void:
	var previous_value := _current_value

	_current_value = clampf(
		new_value,
		0.0,
		_max_value
	)

	# IMPORTANTE:
	#
	# Primero cambia la verdad lógica.
	# Después se anima la representación visual.
	_notify_value_changed()

	if animated:
		_animate_change(
			previous_value,
			_current_value
		)
	else:
		_refresh_values_instant()


func get_percent() -> float:
	if _max_value <= 0.0:
		return 0.0

	return (
		_current_value /
		_max_value
	)


# =========================================================
# ANIMACIÓN
# =========================================================

func _animate_change(
	previous_value: float,
	target_value: float
) -> void:
	var progress_bar := get_node_or_null(
		"ProgressBar"
	) as TextureProgressBar

	var ghost_bar := get_node_or_null(
		"GhostBar"
	) as TextureProgressBar


	if not progress_bar:
		return


	if Engine.is_editor_hint():
		_refresh_values_instant()
		return


	_stop_value_tween()


	var main_start := float(
		progress_bar.value
	)


	# -----------------------------------------------------
	# BARRA PRINCIPAL
	# -----------------------------------------------------

	if smooth_change:
		_value_tween = create_tween()

		_value_tween.set_trans(
			Tween.TRANS_QUAD
		)

		_value_tween.set_ease(
			Tween.EASE_OUT
		)

		_value_tween.tween_method(
			_apply_displayed_value,
			main_start,
			target_value,
			smooth_duration
		)

	else:
		_apply_displayed_value(
			target_value
		)


	# -----------------------------------------------------
	# GHOST BAR
	# -----------------------------------------------------

	if not ghost_enabled:
		if ghost_bar:
			ghost_bar.visible = false

		return


	if not ghost_bar:
		return


	ghost_bar.visible = true


	var is_damage := (
		target_value < previous_value
	)


	if is_damage:
		var ghost_start := maxf(
			float(ghost_bar.value),
			main_start
		)

		ghost_start = maxf(
			ghost_start,
			previous_value
		)

		_apply_ghost_value(
			ghost_start
		)


		_ghost_tween = create_tween()

		_ghost_tween.tween_interval(
			ghost_delay
		)

		_ghost_tween.tween_method(
			_apply_ghost_value,
			ghost_start,
			target_value,
			ghost_duration
		).set_trans(
			Tween.TRANS_QUAD
		).set_ease(
			Tween.EASE_OUT
		)

	else:
		# Curación / regeneración / aumento.
		#
		# No queremos una ghost adelantándose
		# al valor principal.
		_apply_ghost_value(
			main_start
		)


func _stop_value_tween() -> void:
	if _value_tween:
		if _value_tween.is_valid():
			_value_tween.kill()

	_value_tween = null


	if _ghost_tween:
		if _ghost_tween.is_valid():
			_ghost_tween.kill()

	_ghost_tween = null


# =========================================================
# ACTUALIZACIÓN VISUAL
# =========================================================

func _refresh_visuals() -> void:
	var progress_bar := get_node_or_null(
		"ProgressBar"
	) as TextureProgressBar

	var ghost_bar := get_node_or_null(
		"GhostBar"
	) as TextureProgressBar


	if progress_bar:
		progress_bar.texture_under = under_texture
		progress_bar.texture_progress = progress_texture
		progress_bar.texture_over = over_texture


	if ghost_bar:
		ghost_bar.texture_under = null
		ghost_bar.texture_progress = progress_texture
		ghost_bar.texture_over = null

		ghost_bar.tint_progress = ghost_tint

		ghost_bar.visible = ghost_enabled

		if progress_bar:
			ghost_bar.fill_mode = (
				progress_bar.fill_mode
			)


func _refresh_values_instant() -> void:
	_stop_value_tween()

	_update_range()

	_apply_displayed_value(
		_current_value
	)

	_apply_ghost_value(
		_current_value
	)


func _update_range() -> void:
	var progress_bar := get_node_or_null(
		"ProgressBar"
	) as TextureProgressBar

	var ghost_bar := get_node_or_null(
		"GhostBar"
	) as TextureProgressBar


	if progress_bar:
		progress_bar.min_value = 0.0
		progress_bar.max_value = _max_value


	if ghost_bar:
		ghost_bar.min_value = 0.0
		ghost_bar.max_value = _max_value


func _apply_displayed_value(
	displayed_value: float
) -> void:
	var progress_bar := get_node_or_null(
		"ProgressBar"
	) as TextureProgressBar

	var value_label := get_node_or_null(
		"ValueLabel"
	) as Label


	if progress_bar:
		progress_bar.min_value = 0.0
		progress_bar.max_value = _max_value
		progress_bar.value = displayed_value


	if not value_label:
		return


	var percent := 0.0

	if _max_value > 0.0:
		percent = (
			displayed_value /
			_max_value
		) * 100.0


	match text_mode:
		TextMode.HIDDEN:
			value_label.visible = false


		TextMode.CURRENT_MAX:
			value_label.visible = true

			value_label.text = "%d / %d" % [
				roundi(displayed_value),
				roundi(_max_value)
			]


		TextMode.PERCENT:
			value_label.visible = true

			value_label.text = "%d%%" % [
				roundi(percent)
			]


		TextMode.CURRENT_MAX_PERCENT:
			value_label.visible = true

			value_label.text = "%d / %d  %d%%" % [
				roundi(displayed_value),
				roundi(_max_value),
				roundi(percent)
			]


func _apply_ghost_value(
	displayed_value: float
) -> void:
	var ghost_bar := get_node_or_null(
		"GhostBar"
	) as TextureProgressBar


	if not ghost_bar:
		return


	ghost_bar.min_value = 0.0
	ghost_bar.max_value = _max_value

	ghost_bar.value = clampf(
		displayed_value,
		0.0,
		_max_value
	)


# =========================================================
# SIGNALS
# =========================================================

func _notify_value_changed() -> void:
	value_changed.emit(
		_current_value,
		_max_value
	)
