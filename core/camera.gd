class_name LevelCamera3D
extends Camera3D

signal aligned

const FOV_FIRST_PERSON: float = 105.0
const FOV_OVERHEAD: float = 90.0
const TWEEN_DURATION: float = 1.0

@export var is_overhead: bool = false : set = set_overhead

@onready var first_person_pos: Marker3D = $FirstPersonCameraPos
@onready var overhead_pos: Marker3D = $OverheadCameraPos

var tween: Tween


func set_overhead(value: bool) -> void:
	if is_overhead == value:
		return
	is_overhead = value
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	print("Tweening")
	var target_transform: Transform3D
	var target_fov: float
	if is_overhead:
		target_transform = overhead_pos.global_transform
		target_fov = FOV_OVERHEAD
	else:
		target_transform = first_person_pos.global_transform
		target_fov = FOV_FIRST_PERSON
	tween.tween_property(self, "global_transform", target_transform, TWEEN_DURATION)
	tween.tween_property(self, "fov", target_fov, TWEEN_DURATION)
	tween.chain().tween_callback(aligned.emit)
