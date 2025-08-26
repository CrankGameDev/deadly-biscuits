class_name ChocChipBiscuit
extends Biscuit

const MAX_CHOC_CHIPS: int = 14

@export_range(0, MAX_CHOC_CHIPS) var choc_chip_count: int = MAX_CHOC_CHIPS

@onready var model: Node3D = $Model


func _ready() -> void:
	if spawn_settings.has("choc_chip_count"):
		choc_chip_count = spawn_settings.get("choc_chip_count")
	elif spawn_settings.has("choc_chip_min") and spawn_settings.has("choc_chip_max"):
		choc_chip_count = randi_range(spawn_settings.get("choc_chip_min"), spawn_settings.get("choc_chip_max"))
	var indices: Array = range(1, MAX_CHOC_CHIPS + 1)
	indices.shuffle()
	for i in MAX_CHOC_CHIPS - choc_chip_count:
		model.get_node(str("Chip", indices[i])).hide()
