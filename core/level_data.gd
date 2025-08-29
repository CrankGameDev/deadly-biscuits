class_name LevelData
extends Resource


@export_range(0.01, 10.0, 0.01, "or_greater", "suffix:m/s")
var conveyor_speed: float = 1.0

@export_range(0.01, 10.0, 0.01, "or_greater", "suffix:seconds")
var spawn_interval: float = 3.0

@export var critera: Array[Criteria]

@export var spawn_waves: Array[SpawnWave]
