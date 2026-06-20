extends Node3D

@onready var conveyor_pathing: ConveyorPathing = %ConveyorPathing
@export var handle: Node3D
@export var sfx: AudioStreamPlayer3D

var tween: Tween


func _ready() -> void:
	_on_conveyor_pathing_changed(conveyor_pathing.reject_product)


func _on_conveyor_pathing_changed(product_rejected: bool) -> void:
	const HANDLE_ACCEPT_POSITION: float = deg_to_rad(-30.0 + -90.0)
	const HANDLE_REJECT_POSITION: float = deg_to_rad(30.0 + -90.0)
	sfx.play()
	if tween:
		tween.kill()
	if product_rejected:
		tween = create_tween()
		tween.tween_property(handle, "rotation:x", HANDLE_REJECT_POSITION, 0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		tween = create_tween()
		tween.tween_property(handle, "rotation:x", HANDLE_ACCEPT_POSITION, 0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_clickable_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		conveyor_pathing.toggle_rejection()
