extends Node3D

@onready var checklist: CanvasLayer = %Checklist


func _on_clickable_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		checklist.visible = !checklist.visible
