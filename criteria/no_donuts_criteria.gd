class_name NoDonutsCriteria
extends Criteria


func _check_biscuit(biscuit: Biscuit) -> bool:
	return not biscuit is Donut


func _get_text() -> String:
	return "No doughnuts allowed."
