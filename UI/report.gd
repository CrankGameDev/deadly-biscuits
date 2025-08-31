extends Control

const MAIN_MENU_SCENE: PackedScene = preload("uid://bia5rf3vkvbx7")

const FREED_ENDING: PackedScene = preload("uid://78lun7tgsj4w")
const INCINERATED_ENDING: PackedScene = preload("uid://bcako21f33r4")

@onready var day_label: Label = $"Report stats/DayLabel"
@onready var mistakes_label: Label = %MistakesLabel
@onready var processed_label: Label = %ProcessedLabel
@onready var pass_label: Label = %PassLabel
@onready var next_level: Button = %NextLevel

@onready var level: int = SceneManager.scene_params.get("level", 0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	day_label.text = day_label.text.format(SceneManager.scene_params) 
	mistakes_label.text = mistakes_label.text.format(SceneManager.scene_params.get("stats")) 
	processed_label.text = processed_label.text.format(SceneManager.scene_params.get("stats")) 
	
	if SceneManager.scene_params.get("failed"):
		pass_label.text = [
			"You are the worst. YOU ARE FIRED!", 
			"FIRED! Get out of my face!!!", 
			"You are the worst employee we have ever had!!! GET OUT OF MY FACE"
		].pick_random()
		next_level.hide()
	else:	
		pass_label.text = [
			"Acceptable", 
			"Good Enough", 
			"Pass"
		].pick_random()
		next_level.show()


func _on_retry_pressed() -> void:
	LevelManager.load_level_scene(level)


func _on_next_level_pressed() -> void:
	if level < LevelManager.get_level_count():
		LevelManager.load_level_scene(level + 1)
	else:
		if SceneManager.scene_params.stats.tentacle_freed:
			SceneManager.change_scene_to_packed(FREED_ENDING)
		else:
			SceneManager.change_scene_to_packed(INCINERATED_ENDING)


func _on_quit_pressed() -> void:
	SceneManager.change_scene_to_packed(MAIN_MENU_SCENE)
