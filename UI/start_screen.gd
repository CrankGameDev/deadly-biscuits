extends Control


func _on_start_day_pressed() -> void:
	LevelManager.load_level_scene()


func _on_quit_job_pressed() -> void:
	get_tree().quit()


func _on_reset_save_confirmed() -> void:
	Persistence.reset_game()
