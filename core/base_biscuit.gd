class_name Biscuit
extends PathFollow3D

signal destination_reached(accepted: bool)

@onready var conveyor_pathing: ConveyorPathing = get_tree().get_first_node_in_group(&"ConveyorPathing")

## A dictionary of dynamic settings passed in during spawning. [br]
## These are typically read and applied in the [code]_ready[/code] function.
var spawn_settings: Dictionary


func _process(delta: float) -> void:
	if progress_ratio < 1.0:
		# While not at the end of the current path, keep progressing.
		progress += conveyor_pathing.conveyor_speed * delta
	else:
		# TODO: Matching the parent is probably not the most optimal choice.
		#		Just temporary prototyping for now.
		match get_parent():
			conveyor_pathing.base_path:
				reparent(conveyor_pathing.get_target_path())
				progress = 0.0
			conveyor_pathing.accepted_path:
				destination_reached.emit(true)
				set_process(false)
			conveyor_pathing.denied_path:
				destination_reached.emit(false)
				set_process(false)
