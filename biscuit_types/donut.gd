class_name Donut
extends Biscuit

@export var has_eye: bool = false
@onready var eye_mesh: MeshInstance3D = $"Downut eye/EyeMesh"


func _ready() -> void:
	if spawn_settings.has("has_eye"):
		has_eye = spawn_settings.get("has_eye")
	if has_eye:
		eye_mesh.show()
	else:
		eye_mesh.hide()
