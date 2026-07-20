## Represents of a wave of contiguously spawned biscuits.
class_name SpawnWave
extends Resource

@export var spawn_events: Dictionary[SpawnEvent, int]

## The interval between each biscuit being added.
@export_range(0.01, 5.0, 0.01, "or_greater", "suffix:s")
var spawn_interval: float = 3.0

## The randomization added to the interval between each biscuit.
@export_range(0.0, 1.0, 0.01, "or_greater", "suffix:s")
var spawn_interval_randomization: float = 0.0

## The minimum amount of time to wait between the [i]beginning[/i]
## of this wave and the start of the next wave.
@export_range(0.00, 10.0, 0.01, "or_greater", "suffix:s")
var wave_duration: float


func get_shuffled_wave_array(rng: RandomNumberGenerator = null) -> Array[SpawnEvent]:
	var array: Array[SpawnEvent]
	for spawn_event in spawn_events:
		var quantity: int = spawn_events[spawn_event]
		if quantity < 1:
			continue
		var to_append: Array[SpawnEvent]
		to_append.resize(quantity)
		to_append.fill(spawn_event)
		array.append_array(to_append)
	if rng:
		RandomUtil.shuffle_array(rng, array)
	else:
		array.shuffle()
	return array
