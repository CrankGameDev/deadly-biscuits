extends Control

func _on_start_day_pressed() -> void:
	get_tree().change_scene_to_file("res://core/game.tscn")


func _on_quit_job_pressed() -> void:
	get_tree().quit()
