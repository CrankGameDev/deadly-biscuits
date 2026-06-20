class_name NoBugsCriteria
extends Criteria


func _check_biscuit(biscuit: Biscuit) -> bool:
	if biscuit is ChocChipBiscuit:
		if biscuit.bug_count > 0:
			return false
	return true


func _get_text() -> String:
	return "No bugs on biscuits"
