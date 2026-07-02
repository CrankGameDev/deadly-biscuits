extends Node

const LEVEL_SCENE_PATH: String = "uid://dsf6itp1pf21l"
const REPORT_SCENE_PATH: String = "uid://bcgjkpkf7p7bg"

const LEVEL_LIST: LevelList = preload("uid://dkjf0raciy1bl")

## Stores whether level resources have been precached yet.
## When this is [code]true[/code] this will avoid running loading
## and precaching of level resources before entering a level.
var level_resources_precached: bool = false


func get_current_level() -> LevelData:
	return LEVEL_LIST.get_level(Persistence.save_data.current_level)


func get_level_data(level_number: int) -> LevelData:
	return LEVEL_LIST.get_level(level_number)


func get_active_level() -> LevelData:
	var level: Level = get_tree().current_scene as Level
	if level:
		return level.level_data
	else:
		return SceneManager.scene_params.get("level_data") as LevelData


func get_level_count() -> int:
	return LEVEL_LIST.levels.size()


func has_level(level_number: int) -> bool:
	return LEVEL_LIST.has_level(level_number)


func has_level_resources_loaded(level_number: int = Persistence.save_data.current_level) -> bool:
	var level_data: LevelData = get_level_data(level_number)
	if not level_data:
		return false
	for resource: String in level_data.get_resource_list():
		if not ResourceLoader.has_cached(resource):
			return false
	return true


func load_all_level_resources() -> void:
	const LOADING_SCENE_PATH: String = "uid://pujolvn42iou"
	var resources: Dictionary[String, bool]
	resources[LEVEL_SCENE_PATH] = true
	resources[REPORT_SCENE_PATH] = true
	for level: LevelData in LEVEL_LIST.levels:
		for resource: String in level.get_resource_list():
			resources[resource] = true
	var resources_to_load: PackedStringArray
	for resource: String in resources.keys():
		if not ResourceLoader.has_cached(resource) and ResourceLoader.exists(resource):
			resources_to_load.append(resource)
	if not resources_to_load.is_empty():
		var load_screen: Node = load(LOADING_SCENE_PATH).instantiate()
		load_screen.resource_paths = resources_to_load
		load_screen.cache_resources = true
		SceneManager.change_scene_to_node(load_screen)
		await load_screen.finished
	level_resources_precached = true


func load_level_scene(level_number: int = Persistence.save_data.current_level) -> void:
	if not level_resources_precached:
		await load_all_level_resources()
	var level_data: LevelData = LEVEL_LIST.get_level(level_number)
	if not level_data:
		push_error("No data for level '%d'" % level_number)
		return
	var error: Error = await SceneManager.change_scene_to_file(LEVEL_SCENE_PATH, { 
		"level_data": level_data,
		"level": level_number,
	})
	if error:
		push_error("Error loading level scene for level '%d': %s" % [level_number, error_string(error)])


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
	SceneManager.change_scene_to_file(REPORT_SCENE_PATH, {
		"failed": !passed,
		"level": level_number,
		"stats": stats,
	})
