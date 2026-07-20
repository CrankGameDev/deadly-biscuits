class_name Level
extends Node

signal level_completed
signal level_failed

signal spawning_completed

signal biscuit_rejected(biscuit: Biscuit, was_correct: bool)
signal biscuit_accepted(biscuit: Biscuit, was_correct: bool)

signal biscuit_correct(biscuit: Biscuit)
signal biscuit_incorrect(biscuit: Biscuit, failed_criteria: Array[Criteria])

signal level_duration_elapsed

signal conveyor_cleared

@export var level_data: LevelData
@export var nausea_mode: bool = false

@onready var conveyor_pathing: ConveyorPathing = %ConveyorPathing
@onready var camera: LevelCamera3D = $Camera
@onready var intercom_sfx: AudioStreamPlayer3D = %IntercomSFX
@onready var intercom_animation: AnimationPlayer = %IntercomAnimation
@onready var environment_animation: AnimationPlayer = %EnvironmentAnimation
@onready var checklist: CanvasLayer = %Checklist
@onready var distribution_indicators: DistributionIndicators = %DistributionIndicators

#region Tentacle Monster Nodes
@onready var tentacle_stage_1: MeshInstance3D = $"Feetee Creep-1/Root/Volume119"
@onready var tentacle_stage_2: MeshInstance3D = $"Feetee Creep-1/Root/Volume118"
@onready var tentacle_stage_3: MeshInstance3D = $"Feetee Creep-1/Root/Volume117"
@onready var tentacle_stage_4: MeshInstance3D = $"Feetee Creep-1/Root/Volume65"
#endregion

var is_level_started: bool = false
var is_spawning_complete: bool = false

var level_duration_timer: Timer
var biscuits_processed: int = 0
var mistakes_made: int = 0
var mistakes: Array[MistakeData]

var min_spawn_distance: float = 0.0

## A queue of all spawn waves yet to be processed, in reversed order.
var spawn_waves_left: Array[SpawnWave]

## The current spawn wave being processed.
var current_wave: SpawnWave

## The cumulative conveyor distance passed since the last spawn event.
var last_spawn_distance: float = INF

var spawn_event_queue: Array[SpawnEvent]

var next_spawn_interval: float = 0.0
var last_spawn_time: float = 0.0

## How much time must pass before the the next wave can begin.
var next_wave_interval: float = 0.0

## The amount of time that has passed since the previous wave started.
var last_wave_time: float = 0.0

var active_biscuits: Dictionary[Biscuit, bool]

var is_failed: bool = false

var rng: RandomNumberGenerator

enum TentacleState {
	NO_TENTACLE = 0,
	TENTACLE_INCINERATED = 1,
	TENTACLE_FREED = 2,
}

var tentacle_state: TentacleState = TentacleState.NO_TENTACLE


func _init() -> void:
	rng = RandomNumberGenerator.new()


func _enter_tree() -> void:
	var data_param: Variant = SceneManager.scene_params.get("level_data")
	if data_param is LevelData:
		level_data = data_param


func _ready() -> void:
	set_process(false)
	var level: int = SceneManager.scene_params.get("level", 0)
	
	#region Tentacle Monster Management
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
	#endregion
	
	if not level_data:
		printerr("No level data provided.")
		return
	
	if level_data.level_start_dialogue:
		Dialogic.start(level_data.level_start_dialogue)
		%IntercomAnimation.play("talk")
		await Dialogic.timeline_ended
		%IntercomAnimation.stop()
	
	camera.is_overhead = true
	min_spawn_distance = level_data.min_biscuit_distance
	conveyor_pathing.conveyor_speed = level_data.conveyor_speed

	checklist.show()
	
	level_duration_timer = Timer.new()
	level_duration_timer.wait_time = level_data.level_duration
	level_duration_timer.one_shot = true
	level_duration_timer.autostart = false
	level_duration_timer.timeout.connect(_on_duration_timeout)
	add_child(level_duration_timer, false, Node.INTERNAL_MODE_FRONT)

	# Start the level once the checklist is closed.
	checklist.hidden.connect(_start_level, CONNECT_ONE_SHOT)

	
	#for spawn_wave in level_data.spawn_waves:
		#_spawn_events_left.append_array(spawn_wave.get_shuffled_wave_array())
	#_spawn_events_left.reverse()
	
	for criteria in level_data.critera:
		criteria._setup(self)
	
	spawn_waves_left = level_data.spawn_waves.duplicate(false)
	spawn_waves_left.reverse()


func _start_level() -> void:
	level_duration_timer.start()
	set_process(true)
	is_level_started = true
	# _trigger_next_spawn_wave()


func _trigger_next_spawn_wave() -> void:
	if is_spawning_complete:
		return
	if spawn_waves_left.is_empty():
		_flag_spawning_complete()
		return
	current_wave = spawn_waves_left.pop_back()
	spawn_event_queue.clear()
	next_spawn_interval = 0.0
	next_wave_interval = 0.0
	if not current_wave:
		return
	last_wave_time = 0.0
	next_wave_interval = current_wave.wave_duration
	spawn_event_queue = current_wave.get_shuffled_wave_array(rng)
	_compute_next_spawn_interval()


func _compute_next_spawn_interval() -> void:
	if not current_wave or spawn_event_queue.is_empty():
		next_spawn_interval = 0.0
		return
	var interval: float = current_wave.spawn_interval
	var randomization: float = current_wave.spawn_interval_randomization
	if randomization > 0.0:
		next_spawn_interval = maxf(0.0, interval + randf_range(-randomization, randomization))
	else:
		next_spawn_interval = interval


func _attach_biscuit(biscuit: Biscuit) -> void:
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
		intercom_animation.play("talk")
		intercom_sfx.play()
		intercom_sfx.finished.connect(intercom_animation.stop, CONNECT_ONE_SHOT)
		if nausea_mode:
			camera.is_overhead = false
			intercom_sfx.finished.connect(camera.set.bind("is_overhead", true), CONNECT_ONE_SHOT)
	
	var failed_criteria: Array[Criteria]
	for entry in level_data.critera:
		if not entry._check_biscuit(biscuit):
			failed_criteria.append(entry)
	var should_be_accepted: bool = failed_criteria.is_empty()
	var was_correct: bool = accepted == should_be_accepted
	
	if biscuit is TentacleObject:
		was_correct = true
		tentacle_state = TentacleState.TENTACLE_FREED if accepted else TentacleState.TENTACLE_INCINERATED

	if accepted:
		biscuit_accepted.emit(biscuit, was_correct)
	else:
		biscuit_rejected.emit(biscuit, was_correct)
	if was_correct:
		biscuit_correct.emit(biscuit)
	else:
		_on_biscuit_incorrect(biscuit, failed_criteria)
	active_biscuits.erase(biscuit)
	if is_spawning_complete and active_biscuits.is_empty():
		_on_conveyor_cleared()
	biscuit.queue_free()


func _on_duration_timeout() -> void:
	level_duration_timer.stop()
	level_duration_elapsed.emit()
	if not active_biscuits.is_empty():
		await conveyor_cleared
	else:
		_on_conveyor_cleared()
	_on_level_ended()


func _on_level_ended() -> void:
	environment_animation.play("fade_in", -1, -0.5, true)
	await environment_animation.animation_finished
	var stats: Dictionary = {
		"mistakes_made": mistakes_made,
		"biscuits_processed": biscuits_processed,
		"mistakes": mistakes,
	}
	if tentacle_state != TentacleState.NO_TENTACLE:
		if tentacle_state == TentacleState.TENTACLE_FREED:
			stats["tentacle_freed"] = true
		else:
			stats["tentacle_freed"] = false
	LevelManager.notify_level_finished(level_data, not is_failed, stats)


func get_level_duration_ratio() -> float:
	if not level_duration_timer:
		return 0.0
	return 1.0 - level_duration_timer.time_left / level_duration_timer.wait_time


func _on_biscuit_incorrect(biscuit: Biscuit, failed_criteria: Array[Criteria]) -> void:
	mistakes_made += 1
	var mistake_data: MistakeData = MistakeData.new()
	mistake_data.biscuit_scene = biscuit.scene_file_path
	mistake_data.biscuit_params = biscuit.spawn_settings
	for criteria: Criteria in failed_criteria:
		mistake_data.failed_criteria[criteria] = criteria.get_failure_reason(biscuit)
	mistakes.append(mistake_data)
	biscuit_incorrect.emit(biscuit, failed_criteria)


func _on_conveyor_cleared() -> void:
	conveyor_cleared.emit()


func _is_wave_finished() -> bool:
	return spawn_event_queue.is_empty()


func _can_start_next_wave() -> bool:
	return (
		_is_wave_finished()
		and last_wave_time >= next_wave_interval
	)


# Returns whether a subsequent biscuit can be spawned.
# This requires:
# 1. There to still be spawn events remaining for this wave
# 2. Sufficient time to have passed since the last biscuit spawn
# 3. The last spawned biscuit to be at a sufficient distance
func _can_spawn_biscuit() -> bool:
	return (
		not spawn_event_queue.is_empty()
		and last_spawn_distance >= min_spawn_distance
		and last_spawn_time >= next_spawn_interval
	)


func _spawn_next_biscuit() -> void:
	if is_spawning_complete:
		return
	var event: SpawnEvent = spawn_event_queue.pop_back()
	var biscuit: Biscuit = event.spawn()
	_attach_biscuit(biscuit)
	last_spawn_time = 0.0
	last_spawn_distance = 0.0


func _process(delta: float) -> void:
	# Advance Timers & Trackers
	last_spawn_time += delta
	last_wave_time += delta
	last_spawn_distance += conveyor_pathing.conveyor_speed * delta

	# If there is no active wave
	if spawn_event_queue.is_empty():
		# Check if waves are queued
		if not spawn_waves_left.is_empty():
			# If the next wave can start
			if _can_start_next_wave():
				# Start the next wave
				_trigger_next_spawn_wave()
		else:
			# If no waves are queued, flag spawning as completed
			_flag_spawning_complete()
	# Otherwise, if the next biscuit can be spawned
	if _can_spawn_biscuit():
		# Spawn it!
		_spawn_next_biscuit()
		# Determine when the next biscuit should be spawned
		_compute_next_spawn_interval()


func _flag_spawning_complete() -> void:
	if is_spawning_complete:
		return
	is_spawning_complete = true
	set_process(false)
	spawning_completed.emit()
