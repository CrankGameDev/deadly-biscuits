class_name Criteria
extends Resource


## Check whether the given [param biscuit] passes this criteria.
func _check_biscuit(biscuit: Biscuit) -> bool:
	# Virtual method.
	return true


## Gets a text string describing this criteria.
func _get_text() -> String:
	# Virtual method.
	return "Undefined criteria."
