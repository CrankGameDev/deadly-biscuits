class_name BugAllowanceCriteria
extends Criteria

@export var total_bugs_allowed: int = 0

var bugs_counted: int = 0


func _check_biscuit(biscuit: Biscuit) -> bool:
	if biscuit is ChocChipBiscuit:
		if (bugs_counted + biscuit.bug_count) > total_bugs_allowed:
			return false
		bugs_counted += biscuit.bug_count
	return true
