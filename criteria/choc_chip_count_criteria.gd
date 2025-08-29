class_name ChocChipCountCriteria
extends Criteria

enum Operation {
	## Greater than [member count].
	GREATER_THAN,
	## Less than [member count].
	LESS_THAN,
	## Exactly [member count].
	EQUALS,
	## Anything but [member count].
	NOT_EQUALS,
}

## The operation to apply.
@export var operation: Operation = Operation.GREATER_THAN

## The count to use for the operation.
@export var count: int


func _check_biscuit(biscuit: Biscuit) -> bool:
	if biscuit is ChocChipBiscuit:
		match operation:
			Operation.GREATER_THAN:
				return biscuit.choc_chip_count > count
			Operation.LESS_THAN:
				return biscuit.choc_chip_count < count
			Operation.EQUALS:
				return biscuit.choc_chip_count == count
			Operation.NOT_EQUALS:
				return biscuit.choc_chip_count != count
			_:
				push_error("Unsupported operation.")
				return false
	else:
		# Ignore non choc chip biscuits.
		return true


func _get_text() -> String:
	var operation_text: String
	match operation:
		Operation.GREATER_THAN:
			operation_text = str(count + 1, " or more")
		Operation.LESS_THAN:
			operation_text = str(count - 1, " or less")
		Operation.EQUALS:
			operation_text = str("Exactly ", count)
		Operation.NOT_EQUALS:
			operation_text = str("Not ", count)
	return str(operation_text, " chocolate chips")


func _set(property: StringName, value: Variant) -> bool:
	if property == &"operation" and value is String:
		value = value.to_upper()
		if Operation.has(value):
			operation = Operation.get(value)
			return true
	return false
