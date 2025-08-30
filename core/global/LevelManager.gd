extends Node

const LEVEL_SCENE: PackedScene = preload("uid://dsf6itp1pf21l")
const REPORT_SCENE: PackedScene = preload("uid://bcgjkpkf7p7bg")
const LEVEL_LIST: LevelList = preload("uid://dkjf0raciy1bl")


func get_current_level() -> LevelData:
	return LEVEL_LIST.get_level(Persistence.save_data.current_level)


func load_level_scene(level_number: int = Persistence.save_data.current_level) -> void:
	var level_data: LevelData = LEVEL_LIST.get_level(level_number)
	if not level_data:
		push_error("No data for level '%d'" % level_number)
		return
	SceneManager.change_scene_to_packed(LEVEL_SCENE, { "level_data": level_data })


func notify_level_failed(level: LevelData, stats: Dictionary) -> void:
	var level_number: int = LEVEL_LIST.get_level_number(level)
	if not level_number:
		push_error("Could not find level number for level \"%s\"" % level.resource_path)
	# TODO: Modify persistent data
	Persistence.save_game()
	SceneManager.change_scene_to_packed(REPORT_SCENE, {
		"failed": true,
		"level": level_number,
		"stats": stats,
	})


func notify_level_passed(level: LevelData, stats: Dictionary) -> void:
	var level_number: int = LEVEL_LIST.get_level_number(level)
	if not level_number:
		push_error("Could not find level number for level \"%s\"" % level.resource_path)
	# TODO: Modify persistent data
	Persistence.save_game()
	SceneManager.change_scene_to_packed(REPORT_SCENE, {
		"failed": false,
		"level": level_number,
		"stats": stats,
	})
