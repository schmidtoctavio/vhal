@tool
class_name BaseWindow
extends PanelContainer


# =========================================================
# SEÑALES
# =========================================================

signal close_requested


# =========================================================
# CONFIGURACIÓN
# =========================================================

@export_group("Window")

@export var window_title: String = "Window":
	set(value):
		window_title = value
		_refresh_title()


@export_group("Movement")

@export var draggable: bool = true

@export var keep_inside_viewport: bool = true


# =========================================================
# ESTADO DE ARRASTRE
# =========================================================

var _is_dragging: bool = false

var _drag_mouse_start: Vector2 = Vector2.ZERO

var _drag_window_start: Vector2 = Vector2.ZERO


# =========================================================
# REFERENCIAS
# =========================================================

@onready var header: Control = (
	$ContentMargin/Content/Header
)


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_refresh_title()


	if Engine.is_editor_hint():
		return


	# -----------------------------------------------------
	# BOTÓN CERRAR
	# -----------------------------------------------------

	var close_button := get_node_or_null(
		"ContentMargin/Content/Header/CloseButton"
	) as TextureButton


	if close_button:
		if not close_button.pressed.is_connected(
			_on_close_button_pressed
		):
			close_button.pressed.connect(
				_on_close_button_pressed
			)


	# -----------------------------------------------------
	# DRAG DEL HEADER
	# -----------------------------------------------------

	if header:
		if not header.gui_input.is_connected(
			_on_header_gui_input
		):
			header.gui_input.connect(
				_on_header_gui_input
			)


# =========================================================
# TÍTULO
# =========================================================

func _refresh_title() -> void:
	var title_label := get_node_or_null(
		"ContentMargin/Content/Header/TitleLabel"
	) as Label


	if title_label:
		title_label.text = window_title


# =========================================================
# CERRAR
# =========================================================

func _on_close_button_pressed() -> void:
	close_requested.emit()


# =========================================================
# INPUT DEL HEADER
# =========================================================

func _on_header_gui_input(
	event: InputEvent
) -> void:
	if not draggable:
		return


	if event is InputEventMouseButton:
		var mouse_event := (
			event as InputEventMouseButton
		)


		if (
			mouse_event.button_index
			!= MOUSE_BUTTON_LEFT
		):
			return


		if mouse_event.pressed:
			_start_dragging()

		else:
			_stop_dragging()


# =========================================================
# COMENZAR DRAG
# =========================================================

func _start_dragging() -> void:
	_is_dragging = true


	_drag_mouse_start = (
		get_viewport().get_mouse_position()
	)


	_drag_window_start = (
		global_position
	)


# =========================================================
# TERMINAR DRAG
# =========================================================

func _stop_dragging() -> void:
	_is_dragging = false


# =========================================================
# MOVIMIENTO
# =========================================================

func _input(
	event: InputEvent
) -> void:
	if Engine.is_editor_hint():
		return


	if not _is_dragging:
		return


	# -----------------------------------------------------
	# MOVIMIENTO DEL MOUSE
	# -----------------------------------------------------

	if event is InputEventMouseMotion:
		var current_mouse := (
			get_viewport().get_mouse_position()
		)


		var mouse_delta := (
			current_mouse
			-
			_drag_mouse_start
		)


		var target_position := (
			_drag_window_start
			+
			mouse_delta
		)


		if keep_inside_viewport:
			target_position = (
				_clamp_to_viewport(
					target_position
				)
			)


		global_position = target_position


	# -----------------------------------------------------
	# SOLTAMOS EL BOTÓN FUERA DEL HEADER
	# -----------------------------------------------------

	elif event is InputEventMouseButton:
		var mouse_event := (
			event as InputEventMouseButton
		)


		if (
			mouse_event.button_index
			== MOUSE_BUTTON_LEFT
			and
			not mouse_event.pressed
		):
			_stop_dragging()


# =========================================================
# LIMITAR A LA PANTALLA
# =========================================================

func _clamp_to_viewport(
	target_position: Vector2
) -> Vector2:
	var viewport_rect := (
		get_viewport().get_visible_rect()
	)


	var viewport_size := (
		viewport_rect.size
	)


	var max_x := maxf(
		viewport_size.x - size.x,
		0.0
	)


	var max_y := maxf(
		viewport_size.y - size.y,
		0.0
	)


	return Vector2(
		clampf(
			target_position.x,
			0.0,
			max_x
		),

		clampf(
			target_position.y,
			0.0,
			max_y
		)
	)
