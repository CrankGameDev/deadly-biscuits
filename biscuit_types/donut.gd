class_name Donut
extends Biscuit

@export var has_eye: bool = false


func _ready() -> void:
	if spawn_settings.has("has_eye"):
		has_eye = spawn_settings.get("has_eye")
	
	if has_eye:
		set_process(true)
