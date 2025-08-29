class_name OrCriteria
extends Criteria

@export var any_of: Array[Criteria]


func _check_biscuit(biscuit: Biscuit) -> bool:
	for criteria in any_of:
		if criteria._check_biscuit(biscuit):
			return true
	return false


func _get_text() -> String:
	var criteria_strings := PackedStringArray(
		any_of.map(func(criteria: Criteria) -> String: 
			var text: String = criteria._get_text()
			if not text:
				return ""
			# De-capitalize the sentence.
			return text[0].to_lower() + text.substr(1, -1)
			)
	)
	var result: String = " or ".join(criteria_strings)
	if not result:
		return ""
	# Re-capitalize the sentence.
	return result[0].to_upper() + result.substr(1, -1)
