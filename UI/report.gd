extends Control

@onready var day_label: Label = $"Report stats/DayLabel"
@onready var mistakes_label: Label = %MistakesLabel
@onready var processed_label: Label = %ProcessedLabel
@onready var pass_label: Label = %PassLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.scene_params
	day_label.text = day_label.text.format(SceneManager.scene_params) 
	mistakes_label.text = mistakes_label.text.format(SceneManager.scene_params.get("stats")) 
	processed_label.text = processed_label.text.format(SceneManager.scene_params.get("stats")) 
	
	if SceneManager.scene_params.get("failed"):
		pass_label.text = [
			#"You are the worst. YOU ARE FIRED!", 
			#"FIRED! Get out of my face!!!", 
			"You are the worst employee we have ever had!!! GET OUT OF MY FACE"
		].pick_random()
	else:	
		pass_label.text = [
			"Acceptable", "Good Enough", 
		].pick_random()
