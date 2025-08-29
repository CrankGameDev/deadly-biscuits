class_name FrecklesBiscuit
extends Biscuit

@export_range(0, 7, 1)
var mushroom_count: int = 0


func _ready() -> void:
	if spawn_settings.has("mushroom_count"):
		mushroom_count = spawn_settings.get("mushroom_count")
	elif spawn_settings.has("mushroom_min") and spawn_settings.has("mushroom_max"):
		mushroom_count = randi_range(spawn_settings.get("mushroom_min"), spawn_settings.get("mushroom_max"))
	mushroom_count = clampi(mushroom_count, 0, 7)
	
	# Randomize mushrooms.
	var indices: Array = range(1, 8)
	indices.shuffle()
	var mushroom_indices: Array = indices.slice(0, mushroom_count)
	var freckle_indices: Array = indices.slice(mushroom_count)
	for i in mushroom_indices:
		get_node("Model/Mushroom" + str(i)).show()
		get_node("Model/Freckle" + str(i)).hide()
	for i in freckle_indices:
		get_node("Model/Freckle" + str(i)).show()
		get_node("Model/Mushroom" + str(i)).hide()
	
