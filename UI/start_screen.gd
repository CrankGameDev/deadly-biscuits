extends Control

const SETTINGS_SCENE_PATH: String = "uid://jnlpl51k3cg2"


func _on_start_day_pressed() -> void:
	LevelManager.load_level_scene()


func _on_quit_job_pressed() -> void:
	get_tree().quit()


func _on_reset_save_confirmed() -> void:
	Persistence.reset_game()


func _on_game_settings_pressed() -> void:
	var settings: Control = load(SETTINGS_SCENE_PATH).instantiate()
	settings.back_button_pressed.connect(
		SceneManager.change_scene_to_file.bind(self.scene_file_path)
	)
	SceneManager.change_scene_to_node(settings)
