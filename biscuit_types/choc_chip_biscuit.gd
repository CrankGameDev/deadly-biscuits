extends Biscuit

const MAX_CHOC_CHIPS: int = 14

@export_range(0, MAX_CHOC_CHIPS) var chocolate_chip_count: int = MAX_CHOC_CHIPS

@onready var model: Node3D = $Model


func _ready() -> void:
	var indices: Array = range(1, MAX_CHOC_CHIPS + 1)
	indices.shuffle()
	for i in MAX_CHOC_CHIPS - chocolate_chip_count:
		model.get_node(str("Chip", indices[i])).hide()
