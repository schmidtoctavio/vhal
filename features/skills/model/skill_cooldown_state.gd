class_name SkillCooldownState
extends RefCounted


# =========================================================
# ESTADO
#
# Guardamos un vencimiento LOCAL calculado desde el
# remaining informado por el Game Server.
#
# IMPORTANTE:
#
# Esto NO autoriza casts.
# Sólo permite representar visualmente el cooldown entre
# una sincronización autoritativa y la siguiente.
# =========================================================

var _expires_at_msec_by_skill: Dictionary = {}


# =========================================================
# SINCRONIZACIÓN AUTORITATIVA
# =========================================================

func sync_authoritative(
	skill_id: String,
	remaining_seconds: float
) -> bool:
	var normalized_skill_id := (
		skill_id
		.strip_edges()
		.to_lower()
	)


	if normalized_skill_id.is_empty():
		return false


	if normalized_skill_id.length() > 64:
		return false


	if remaining_seconds < 0.0:
		return false


	# -----------------------------------------------------
	# SIN COOLDOWN
	#
	# El servidor explícitamente nos indica que esta skill
	# ya no posee cooldown activo.
	# -----------------------------------------------------

	if remaining_seconds <= 0.0:
		_expires_at_msec_by_skill.erase(
			normalized_skill_id
		)


		return true


	# -----------------------------------------------------
	# CONVERTIR REMAINING → EXPIRATION LOCAL
	#
	# Este reloj NO es autoridad de gameplay.
	# Es únicamente nuestra proyección visual.
	# -----------------------------------------------------

	var remaining_msec := maxi(
		int(
			ceil(
				remaining_seconds * 1000.0
			)
		),
		1
	)


	_expires_at_msec_by_skill[
		normalized_skill_id
	] = (
		Time.get_ticks_msec()
		+
		remaining_msec
	)


	return true


# =========================================================
# CONSULTAR TIEMPO RESTANTE
# =========================================================

func get_remaining_seconds(
	skill_id: String
) -> float:
	var normalized_skill_id := (
		skill_id
		.strip_edges()
		.to_lower()
	)


	if normalized_skill_id.is_empty():
		return 0.0


	if not _expires_at_msec_by_skill.has(
		normalized_skill_id
	):
		return 0.0


	var expires_at_msec := int(
		_expires_at_msec_by_skill[
			normalized_skill_id
		]
	)


	var remaining_msec := (
		expires_at_msec
		-
		Time.get_ticks_msec()
	)


	if remaining_msec <= 0:
		_expires_at_msec_by_skill.erase(
			normalized_skill_id
		)


		return 0.0


	return (
		float(remaining_msec)
		/
		1000.0
	)


# =========================================================
# CONSULTAR SI ESTÁ ACTIVO
# =========================================================

func is_on_cooldown(
	skill_id: String
) -> bool:
	return (
		get_remaining_seconds(
			skill_id
		)
		>
		0.0
	)


# =========================================================
# RESET
# =========================================================

func clear() -> void:
	_expires_at_msec_by_skill.clear()
