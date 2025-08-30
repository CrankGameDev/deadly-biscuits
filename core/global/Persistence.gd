extends Node

const SAVE_PATH: String = "user://save_data.res"

var save_data: SaveData


func _ready() -> void:
	load_game()


func load_game() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		save_data = ResourceLoader.load(SAVE_PATH)
	else:
		reset_game()


func save_game() -> void:
	ResourceSaver.save(save_data, SAVE_PATH, ResourceSaver.FLAG_COMPRESS)


func reset_game() -> void:
	save_data = SaveData.new()
	save_game()
