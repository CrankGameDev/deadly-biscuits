class_name NoBugsCriteria
extends Criteria


func _check_biscuit(biscuit: Biscuit) -> bool:
	if biscuit is ChocChipBiscuit:
		if biscuit.bug_count > 0:
			return false
	return true


func _get_failure_reason_text(biscuit: Biscuit) -> String:
	if biscuit is ChocChipBiscuit:
		var bug_count: int = biscuit.bug_count
		if bug_count > 0:
			return "Product contained %d roaches." % bug_count
	return ""


func _get_text() -> String:
	return "No bugs on biscuits"
