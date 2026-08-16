@tool
class_name SkillsWindow
extends BaseWindow


# =========================================================
# ESCENAS
# =========================================================

const SKILL_BOOK_SLOT_SCENE := preload(
    "res://features/skills/ui/skill_book_slot.tscn"
)


# =========================================================
# REFERENCIAS
# =========================================================

@onready var skills_grid: GridContainer = (
	$ContentMargin/Content/Body/SkillsContent/SkillsScroll/SkillsGrid
)


# =========================================================
# DATOS
# =========================================================

var skill_book_data: SkillBookData = null


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	super._ready()
	
	if Engine.is_editor_hint():
		return


	_refresh_skill_grid()


# =========================================================
# VINCULAR SKILL BOOK
# =========================================================

func bind_skill_book(
	data: SkillBookData
) -> void:

	# -----------------------------------------------------
	# DESCONECTAR MODELO ANTERIOR
	# -----------------------------------------------------

	if skill_book_data != null:
		if skill_book_data.changed.is_connected(
			_on_skill_book_changed
		):
			skill_book_data.changed.disconnect(
				_on_skill_book_changed
			)


	# -----------------------------------------------------
	# GUARDAR NUEVO MODELO
	# -----------------------------------------------------

	skill_book_data = data


	# -----------------------------------------------------
	# CONECTAR NUEVO MODELO
	# -----------------------------------------------------

	if skill_book_data != null:
		if not skill_book_data.changed.is_connected(
			_on_skill_book_changed
		):
			skill_book_data.changed.connect(
				_on_skill_book_changed
			)


	# -----------------------------------------------------
	# ACTUALIZAR UI
	# -----------------------------------------------------

	if is_node_ready():
		_refresh_skill_grid()


# =========================================================
# CAMBIO EN SKILL BOOK
# =========================================================

func _on_skill_book_changed() -> void:
	_refresh_skill_grid()


# =========================================================
# REFRESCAR GRILLA
# =========================================================

func _refresh_skill_grid() -> void:
	if not is_node_ready():
		return


	_clear_skill_grid()


	if skill_book_data == null:
		return


	for skill in skill_book_data.get_skills():

		if skill == null:
			continue


		var slot := (
			SKILL_BOOK_SLOT_SCENE.instantiate()
			as SkillBookSlot
		)


		if slot == null:
			continue


		slot.set_skill(
			skill
		)


		skills_grid.add_child(
			slot
		)


# =========================================================
# LIMPIAR GRILLA
# =========================================================

func _clear_skill_grid() -> void:
	for child in skills_grid.get_children():

		skills_grid.remove_child(
			child
		)

		child.queue_free()
