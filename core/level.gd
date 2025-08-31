class_name Level
extends Node

signal level_completed
signal level_failed

signal spawning_completed

signal biscuit_rejected(biscuit: Biscuit, was_correct: bool)
signal biscuit_accepted(biscuit: Biscuit, was_correct: bool)

signal biscuit_correct(biscuit: Biscuit)
signal biscuit_incorrect(biscuit: Biscuit)

@export var level_data: LevelData

@onready var conveyor_pathing: ConveyorPathing = %ConveyorPathing
@onready var camera: LevelCamera3D = $Camera
@onready var intercom_sfx: AudioStreamPlayer3D = %IntercomSFX
@onready var intercom_animation: AnimationPlayer = %IntercomAnimation
@onready var environment_animation: AnimationPlayer = %EnvironmentAnimation
@onready var checklist: CanvasLayer = %Checklist

@onready var tentacle_stage_1: MeshInstance3D = $"Feetee Creep-1/Root/Volume119"
@onready var tentacle_stage_2: MeshInstance3D = $"Feetee Creep-1/Root/Volume118"
@onready var tentacle_stage_3: MeshInstance3D = $"Feetee Creep-1/Root/Volume117"
@onready var tentacle_stage_4: MeshInstance3D = $"Feetee Creep-1/Root/Volume65"


var mistakes_made: int = 0

var biscuits_processed: int = 0

var level_timer: Timer

var _spawn_events_left: Array[SpawnEvent]

var active_biscuits: Dictionary[Biscuit, bool]
var is_failed: bool = false


func _enter_tree() -> void:
	var data_param: Variant = SceneManager.scene_params.get("level_data")
	if data_param is LevelData:
		level_data = data_param


func _ready() -> void:
	
	var level: int = SceneManager.scene_params.get("level", 0)
	tentacle_stage_1.hide()
	tentacle_stage_2.hide()
	tentacle_stage_3.hide()
	tentacle_stage_4.hide()
	if level > 1:
		tentacle_stage_1.show()
	if level > 2:
		tentacle_stage_2.show()
	if level > 3:
		tentacle_stage_3.show()
	if level > 4:
		tentacle_stage_4.show()	
	
	if not level_data:
		printerr("No level data provided.")
		return
	if level_data.level_start_dialogue:
		Dialogic.start(level_data.level_start_dialogue)
		%IntercomAnimation.play("talk")
		await Dialogic.timeline_ended
		%IntercomAnimation.stop()
	
	camera.is_overhead = true
	# Maybe await alignment?
	checklist.show()
	
	level_timer = Timer.new()
	level_timer.autostart = true
	level_timer.wait_time = level_data.spawn_interval
	level_timer.timeout.connect(_on_spawn_interval)
	add_child(level_timer, false, Node.INTERNAL_MODE_FRONT)
	
	conveyor_pathing.conveyor_speed = level_data.conveyor_speed
	
	for spawn_wave in level_data.spawn_waves:
		_spawn_events_left.append_array(spawn_wave.get_shuffled_wave_array())
	_spawn_events_left.reverse()
	
	for criteria in level_data.critera:
		criteria._setup(self)


func _on_spawn_interval() -> void:
	if _spawn_events_left.is_empty():
		_check_spawning_complete()
		return
	var event: SpawnEvent = _spawn_events_left.pop_back()
	var biscuit: Biscuit = event.spawn()
	spawn_biscuit(biscuit)
	_check_spawning_complete()


func _check_spawning_complete() -> void:
	if _spawn_events_left.is_empty():
		spawning_completed.emit()


func spawn_biscuit(biscuit: Biscuit) -> void:
	if not biscuit.is_inside_tree():
		conveyor_pathing.base_path.add_child(biscuit, true)
	elif not biscuit.get_parent() == conveyor_pathing.base_path:
		biscuit.reparent(conveyor_pathing.base_path)
	biscuit.progress = 0.0
	if not biscuit.destination_reached.is_connected(_on_biscuit_destination_reached):
		biscuit.destination_reached.connect(_on_biscuit_destination_reached.bind(biscuit))
	biscuit.set_process(true)
	active_biscuits[biscuit] = true


func _on_biscuit_destination_reached(accepted: bool, biscuit: Biscuit) -> void:
	biscuits_processed += 1
	
	# Randomly add intercom chatter just to make players think it means something :)
	if not intercom_animation.is_playing() and randi_range(0, 5) == 0:
		camera.is_overhead = false
		intercom_animation.play("talk")
		intercom_sfx.play()
		intercom_sfx.finished.connect(intercom_animation.stop, CONNECT_ONE_SHOT)
		intercom_sfx.finished.connect(camera.set.bind("is_overhead", true), CONNECT_ONE_SHOT)
	
	var should_be_accepted: bool = true
	for entry in level_data.critera:
		if not entry._check_biscuit(biscuit):
			should_be_accepted = false
			break	
	var was_correct: bool = accepted == should_be_accepted
	if accepted:
		biscuit_accepted.emit(biscuit, was_correct)
	else:
		biscuit_rejected.emit(biscuit, was_correct)
	if was_correct:
		biscuit_correct.emit(biscuit)
	else:
		biscuit_incorrect.emit(biscuit)
		mistakes_made += 1
		if mistakes_made >= 3:
			level_failed.emit()
			is_failed = true
			# Level failed but let's not tell the player, shush.
			#_on_level_failed()
	active_biscuits.erase(biscuit)
	if _spawn_events_left.is_empty() and active_biscuits.is_empty():
		level_completed.emit()
		_on_level_ended()
	biscuit.queue_free()


func _on_level_ended() -> void:
	environment_animation.play("fade_in", -1, -0.5, true)
	await environment_animation.animation_finished
	LevelManager.notify_level_finished(level_data, !is_failed, {
		"mistakes_made": mistakes_made,
		"biscuits_processed": biscuits_processed,
	})
