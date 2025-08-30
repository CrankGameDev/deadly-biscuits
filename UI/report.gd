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
		pass_label.text = "You are the worst. You are fired!"
	else:	
		pass_label.text = "Acceptable"
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
