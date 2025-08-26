class_name ChocChipCountCriteria
extends Criteria

const ChocChipBiscuitScene: PackedScene = preload("uid://cpylw10v2xhi3")

enum Operation {
	GREATER_THAN,
	LESS_THAN,
}

@export var count: int

@export var operation: Operation = Operation.GREATER_THAN


func _check_biscuit(biscuit: Biscuit) -> bool:
	if biscuit is ChocChipBiscuit:
		match operation:
			Operation.GREATER_THAN:
				return biscuit.choc_chip_count > count
			Operation.LESS_THAN:
				return biscuit.choc_chip_count < count
			_:
				push_error("Unsupported operation.")
				return false
	else:
		# Ignore non choc chip biscuits.
		return true
	
