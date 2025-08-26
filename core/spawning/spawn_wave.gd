## Represents of a wave of contiguously spawned biscuits.
class_name SpawnWave
extends Resource

@export var spawn_events: Dictionary[SpawnEvent, int]


func get_shuffled_wave_array() -> Array[SpawnEvent]:
	var array: Array[SpawnEvent]
	for spawn_event in spawn_events:
		var quantity: int = spawn_events[spawn_event]
		if quantity < 1:
			continue
		var to_append: Array[SpawnEvent]
		to_append.resize(quantity)
		to_append.fill(spawn_event)
		array.append_array(to_append)
	array.shuffle()
	return array
