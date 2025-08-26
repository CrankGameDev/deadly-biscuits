class_name ConveyorPathing
extends Node3D

## A signal emitted when the course of the conveyor is changed.
signal changed(product_rejected: bool)

## The speed (in meters per second) of the conveyor.
@export var conveyor_speed: float = 2.0

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


func _process(delta: float) -> void:
	for biscuit_pather in biscuit_pathers:
		biscuit_pather.progress += conveyor_speed * delta
		if biscuit_pather.progress_ratio >= 1.0:
			# TODO: Matching the parent is probably not the most optimal choice.
			#		Just temporary prototyping for now.
			match biscuit_pather.get_parent():
				base_path:
					biscuit_pather.reparent(denied_path if reject_product else accepted_path)
					biscuit_pather.progress = 0.0
				accepted_path, denied_path:
					# TODO: Handle biscuit reaching destination.
					biscuit_pather.reparent(base_path)
					biscuit_pather.progress = 0.0


func _unhandled_input(event: InputEvent) -> void:
	# TODO: Temporary control
	if event.is_action_pressed("ui_accept"):
		toggle_rejection()


func toggle_rejection() -> void:
		reject_product = !reject_product
		changed.emit(reject_product)
