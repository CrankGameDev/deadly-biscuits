class_name BugAllowanceCriteria
extends Criteria

@export var max_bugs_per_biscuit: int = 0


func _check_biscuit(biscuit: Biscuit) -> bool:
	if biscuit is ChocChipBiscuit:
		if biscuit.bug_count > max_bugs_per_biscuit:
			return false
	return true
