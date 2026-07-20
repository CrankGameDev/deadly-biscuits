class_name RandomUtil

## Performs an array shuffle using a Fisher-Yates technique.
static func shuffle_array(rng: RandomNumberGenerator, array: Array) -> void:
	for i in range(array.size() - 1, 1, -1):
		var j: int = rng.randi_range(0, i)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp
