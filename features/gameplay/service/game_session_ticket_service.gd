class_name GameSessionTicketService
extends RefCounted


# =========================================================
# SIGNALS
# =========================================================

@warning_ignore("unused_signal")
signal ticket_issued(
	ticket: String,
	character_id: int,
	expires_at: String
)

@warning_ignore("unused_signal")
signal ticket_failed(
	message: String
)


# =========================================================
# EMITIR TICKET
# =========================================================

func issue_ticket(
	_character_id: int
) -> void:
	push_error(
		"GameSessionTicketService.issue_ticket() debe ser implementado."
	)
