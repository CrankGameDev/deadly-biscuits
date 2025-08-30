extends Node

const LEVEL_SCENE: PackedScene = preload("uid://dsf6itp1pf21l")
const LEVEL_LIST: LevelList = preload("uid://dkjf0raciy1bl")


func get_first_level() -> LevelData:
	return LEVEL_LIST.get_level(1)


func get_next_level() -> LevelData:
	var current_level: Level = get_tree().current_scene as Level
	if not current_level:
		return null
	if not current_level.level_data:
		return null
	var current_level_number: int = LEVEL_LIST.get_level_number(current_level.level_data)
	return LEVEL_LIST.get_level(current_level_number + 1)


func load_level(level_data: LevelData) -> void:
	assert(level_data, "level_data must not be null.")
	SceneManager.change_scene_to_packed(LEVEL_SCENE, { "level_data": level_data })
