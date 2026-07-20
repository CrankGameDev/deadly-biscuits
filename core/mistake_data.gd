class_name MistakeData
extends Resource

@export var biscuit_scene: String
@export var biscuit_params: Dictionary
@export var was_destroyed: bool
@export var failed_criteria: Dictionary[Criteria, String]


## Compares whether this mistake is equivalent to the given [param other]
## mistake, largely for consolidation purposes.
func is_equal(other: MistakeData) -> bool:
	return (
		was_destroyed == other.was_destroyed
		and biscuit_scene == other.biscuit_scene
		and biscuit_params.recursive_equal(other.biscuit_params, 8)
		and failed_criteria == other.failed_criteria
	)
