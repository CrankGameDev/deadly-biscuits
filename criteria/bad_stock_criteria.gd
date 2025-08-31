class_name BadStockCriteria
extends Criteria


func _check_biscuit(biscuit: Biscuit) -> bool:
	if (
		biscuit is EvilBiscuit
		or biscuit is OatMonsterBiscuit
		or (biscuit is Donut and biscuit.has_eye)
		or (biscuit is FrecklesBiscuit and biscuit.mushroom_count > 0)
	):
		return false
	else:
		return true


func _get_text() -> String:
	return "No weird biscuits"
