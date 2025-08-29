class_name Criteria
extends Resource


## Perform any set up functionality. [br]
## This is called in the 'ready' step.
@warning_ignore("unused_parameter")
func _setup(level: Level) -> void:
	# Virtual method.
	pass


## Check whether the given [param biscuit] passes this criteria.
@warning_ignore("unused_parameter")
func _check_biscuit(biscuit: Biscuit) -> bool:
	# Virtual method.
	return true


## Gets a text string describing this criteria.
func _get_text() -> String:
	# Virtual method.
	return "Undefined criteria."


func _to_string() -> String:
	return "Criteria(\"%s\")" % _get_text()
