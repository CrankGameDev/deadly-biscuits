class_name Biscuit
extends PathFollow3D

@onready var conveyor_pathing: ConveyorPathing = %ConveyorPathing


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
			conveyor_pathing.accepted_path, conveyor_pathing.denied_path:
				# TODO: Handle biscuit reaching destination.
				reparent(conveyor_pathing.base_path)
				progress = 0.0
