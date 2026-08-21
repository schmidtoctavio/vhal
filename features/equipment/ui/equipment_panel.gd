class_name EquipmentPanel
extends PanelContainer


signal item_activated(
	slot_id: StringName,
	item: ItemInstance
)


# =========================================================
# MODELO
# =========================================================

var equipment_data: EquipmentData = null


# =========================================================
# SLOTS
# =========================================================

@onready var equipment_slots: Array[EquipmentSlot] = [
	$ContentMargin/EquipmentLayout/HeadSlot,
	$ContentMargin/EquipmentLayout/ChestSlot,
	$ContentMargin/EquipmentLayout/PantsSlot,
	$ContentMargin/EquipmentLayout/GlovesSlot,
	$ContentMargin/EquipmentLayout/BootsSlot,

	$ContentMargin/EquipmentLayout/MainHandSlot,
	$ContentMargin/EquipmentLayout/OffHandSlot,

	$ContentMargin/EquipmentLayout/WingsSlot,
	$ContentMargin/EquipmentLayout/PendantSlot,

	$ContentMargin/EquipmentLayout/LeftRingSlot,
	$ContentMargin/EquipmentLayout/RightRingSlot
]


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_bind_slots()


# =========================================================
# BIND
# =========================================================

func bind_equipment_data(
	data: EquipmentData
) -> void:
	equipment_data = data


	if is_node_ready():
		_bind_slots()


func _bind_slots() -> void:
	if equipment_data == null:
		return


	for slot in equipment_slots:
		if slot == null:
			continue


		slot.bind_equipment_data(
			equipment_data
		)


		if not slot.item_activated.is_connected(
			_on_slot_item_activated
		):
			slot.item_activated.connect(
				_on_slot_item_activated
			)


func _on_slot_item_activated(
	slot_id: StringName,
	item: ItemInstance
) -> void:
	item_activated.emit(
		slot_id,
		item
	)
