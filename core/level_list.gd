class_name LevelList
extends Resource

@export var levels: Array[LevelData]


func get_level_number(level: LevelData) -> int:
	# Returns 0 if not found.
	return levels.find(level) + 1


func get_level(number: int) -> LevelData:
	var idx: int = number - 1
	if idx < 0 or idx >= levels.size():
		return null
	return levels[idx]
