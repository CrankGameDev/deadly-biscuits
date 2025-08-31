extends Node

const LEVEL_SCENE: PackedScene = preload("uid://dsf6itp1pf21l")
const REPORT_SCENE: PackedScene = preload("uid://bcgjkpkf7p7bg")
const LEVEL_LIST: LevelList = preload("uid://dkjf0raciy1bl")


func get_current_level() -> LevelData:
	return LEVEL_LIST.get_level(Persistence.save_data.current_level)


func get_active_level() -> LevelData:
	var level: Level = get_tree().current_scene as Level
	if level:
		return level.level_data
	else:
		return SceneManager.scene_params.get("level_data")


func get_level_count() -> int:
	return LEVEL_LIST.levels.size()


func load_level_scene(level_number: int = Persistence.save_data.current_level) -> void:
	var level_data: LevelData = LEVEL_LIST.get_level(level_number)
	if not level_data:
		push_error("No data for level '%d'" % level_number)
		return
	SceneManager.change_scene_to_packed(LEVEL_SCENE, { 
		"level_data": level_data,
		"level": level_number,
	})


func notify_level_finished(level: LevelData, passed: bool, stats: Dictionary) -> void:
	var level_number: int = LEVEL_LIST.get_level_number(level)
	if not level_number:
		push_error("Could not find level number for level \"%s\"" % level.resource_path)
	elif passed:
		Persistence.save_data.level_stats[level_number] = stats
		var next_level: int = level_number + 1
		if (Persistence.save_data.current_level < next_level) and LEVEL_LIST.has_level(next_level):
			Persistence.save_data.current_level = next_level
		Persistence.save_game()
	SceneManager.change_scene_to_packed(REPORT_SCENE, {
		"failed": !passed,
		"level": level_number,
		"stats": stats,
	})
