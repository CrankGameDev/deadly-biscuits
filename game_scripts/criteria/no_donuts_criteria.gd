class_name NoDonutsCriteria
extends Criteria


func _check_biscuit(biscuit: Biscuit) -> bool:
	return not biscuit is Donut


func _get_failure_reason_text(biscuit: Biscuit) -> String:
	if biscuit is Donut:
		return "Product is a doughnut."
	return ""


func _get_text() -> String:
	return "No doughnuts allowed."
