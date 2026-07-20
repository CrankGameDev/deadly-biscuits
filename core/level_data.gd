class_name LevelData
extends Resource

@export
var level_start_dialogue: DialogicTimeline

@export_range(0.01, 10.0, 0.01, "or_greater", "suffix:m/s")
var conveyor_speed: float = 1.0

@export_range(0.01, 300.0, 0.01, "or_greater", "suffix:s")
var level_duration: float = 60.0

#@export_range(0.01, 10.0, 0.01, "or_greater", "suffix:s")
#var spawn_interval: float = 3.0

@export_range(0.0, 1.0, 0.01, "or_greater", "suffix:m")
var min_biscuit_distance: float = 0.6

@export var critera: Array[Criteria]

@export var spawn_waves: Array[SpawnWave]


## Gets a list of resources this level scene depends on
## but does not have a resource dependency inclusion for.
func get_resource_list() -> PackedStringArray:
	var resources: Dictionary[String, bool]
	for wave: SpawnWave in spawn_waves:
		if wave == null:
			continue
		for event: SpawnEvent in wave.spawn_events:
			if event == null:
				continue
			var scene_path: String = event.biscuit_scene_path
			if scene_path.is_empty():
				continue
			resources[scene_path] = true
	return PackedStringArray(resources.keys())
