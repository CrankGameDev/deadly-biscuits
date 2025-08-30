class_name ConveyorPathing
extends Node3D

## A signal emitted when the course of the conveyor is changed.
signal changed(product_rejected: bool)

signal started_rejecting

signal stopped_rejecting

## The speed (in meters per second) of the conveyor.
@export var conveyor_speed: float = 1.0

## Whether products are currently being rejected.
@export var reject_product: bool = false

# The conveyor path components.
@onready var base_path: Path3D = $BasePath
@onready var accepted_path: Path3D = $AcceptedPath
@onready var denied_path: Path3D = $DeniedPath


var biscuit_pathers: Array[PathFollow3D]


func _ready() -> void:
	for child in base_path.get_children():
		if child is PathFollow3D:
			biscuit_pathers.append(child)


func get_target_path() -> Path3D:
	return denied_path if reject_product else accepted_path


func _unhandled_input(event: InputEvent) -> void:
	# TODO: Temporary control
	if event.is_action_pressed("ui_accept"):
		toggle_rejection()


func toggle_rejection() -> void:
		reject_product = !reject_product
		changed.emit(reject_product)
		if reject_product:
			started_rejecting.emit()
		else:
			stopped_rejecting.emit()
