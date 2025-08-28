class_name BiscuitManager
extends Node

@onready var conveyor_pathing: ConveyorPathing = %ConveyorPathing

@export var spawn_waves: Array[SpawnWave]

@export_range(0.0, 10.0, 0.01, "or_greater", "suffix:seconds")
var biscuit_interval: float = 3.0

@export var biscuit_criteria: Array[Criteria]

var timer: Timer

var _spawn_events_left: Array[SpawnEvent]


func _ready() -> void:

	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = biscuit_interval
	timer.timeout.connect(_on_spawn_interval)
	add_child(timer, false, Node.INTERNAL_MODE_FRONT)
	for spawn_wave in spawn_waves:
		_spawn_events_left.append_array(spawn_wave.get_shuffled_wave_array())
	_spawn_events_left.reverse()


func _on_spawn_interval() -> void:
	if _spawn_events_left.is_empty():
		return
	var event: SpawnEvent = _spawn_events_left.pop_back()
	var biscuit: Biscuit = event.spawn()
	spawn_biscuit(biscuit)


func spawn_biscuit(biscuit: Biscuit) -> void:
	if not biscuit.is_inside_tree():
		conveyor_pathing.base_path.add_child(biscuit, true)
	elif not biscuit.get_parent() == conveyor_pathing.base_path:
		biscuit.reparent(conveyor_pathing.base_path)
	biscuit.progress = 0.0
	if not biscuit.destination_reached.is_connected(_on_biscuit_destination_reached):
		biscuit.destination_reached.connect(_on_biscuit_destination_reached.bind(biscuit))
	biscuit.set_process(true)


func _on_biscuit_destination_reached(accepted: bool, biscuit: Biscuit) -> void:
	print(("%s was accepted!" if accepted else "%s was rejected!") % biscuit.name)
	var should_be_accepted: bool = true
	for entry in biscuit_criteria:
		if not entry._check_biscuit(biscuit):
			should_be_accepted = false
			break
	if accepted == should_be_accepted:
		print("Good job!")
	else:
		print("How could you!")
	biscuit.queue_free()
	
