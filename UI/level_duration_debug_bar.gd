extends ProgressBar


func _enter_tree() -> void:
	if not OS.is_debug_build():
		queue_free()


func _process(_delta: float) -> void:
	value = owner.get_level_duration_ratio()
