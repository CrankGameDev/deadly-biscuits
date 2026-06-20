class_name HeartBeatingCriteria
extends Criteria

var should_beat: bool = false


func _check_biscuit(biscuit: Biscuit) -> bool:
	if biscuit is HeartBiscuit:
		return biscuit.is_evil == should_beat
	else:
		# Ignore non choc chip biscuits.
		return true


func _get_text() -> String:
	if should_beat:
		return "Hearts must be beating."
	else:
		return "Hearts must not be beating."
