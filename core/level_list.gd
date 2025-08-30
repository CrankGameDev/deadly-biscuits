class_name LevelList
extends Resource

@export var levels: Array[LevelData]


func get_level_number(level: LevelData) -> int:
	# Returns 0 if not found.
	var level_number: int = levels.find(level) + 1
	return level_number


func get_level(number: int) -> LevelData:
	var idx: int = number - 1
	if idx < 0 or idx >= levels.size():
		return null
	return levels[idx]
