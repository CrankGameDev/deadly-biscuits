extends Control

const SETTINGS_SCENE_PATH: String = "uid://jnlpl51k3cg2"
var paused = false
@onready var pause_menu: Control = $"."


func _process(delta): 
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func _on_start_day_pressed() -> void:
	pause_menu.pauseMenu()
	

func _on_game_settings_button_pressed() -> void:
	var settings: Control = load(SETTINGS_SCENE_PATH).instantiate()
	settings.back_button_pressed.connect(
	SceneManager.change_scene_to_file.bind(self.scene_file_path)
	)
	SceneManager.change_scene_to_node(settings)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/start_screen.tscn")

func _on_quit_job_pressed() -> void:
	get_tree().quit()
	
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1 
	else: 
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused 
