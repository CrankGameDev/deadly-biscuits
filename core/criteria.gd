@abstract
class_name Criteria
extends Resource

@export var criteria_text_override: String = ""


func get_text() -> String:
	if criteria_text_override:
		return criteria_text_override
	var text: String = _get_text()
	if text.is_empty():
		push_error("Empty criteria text")
	return text


func get_failure_reason(biscuit: Biscuit) -> String:
	var text: String = _get_failure_reason_text(biscuit)
	if text.is_empty():
		push_error("Empty criteria text")
	return text


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


@warning_ignore("unused_parameter")
func _get_failure_reason_text(biscuit: Biscuit) -> String:
	return ""


## Gets a text string describing this criteria.
func _get_text() -> String:
	# Virtual method.
	return "Undefined criteria."


func _to_string() -> String:
	return "Criteria(\"%s\")" % _get_text()
