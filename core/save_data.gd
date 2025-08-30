class_name SaveData
extends Resource


@export var current_level: int = 1

@export var level_stats: Dictionary[int, Dictionary]


func get_total_biscuits() -> int:
	var count: int = 0
	for stats in level_stats.values():
		count += stats.get("biscuits_processed", 0)
	return count


func get_total_mistakes() -> int:
	var count: int = 0
	for stats in level_stats.values():
		count += stats.get("mistakes_made", 0)
	return count
