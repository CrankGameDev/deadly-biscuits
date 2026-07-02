extends Node

signal finished

signal resource_failed(path: String)
signal resource_loaded(path: String)

@export_file_path("*.tres", "*.res", "*.tscn")
var resource_paths: PackedStringArray

@export var cache_resources: bool = false

var loading_resources: Dictionary[String, float]
var completed_resources: Dictionary[String, Resource]

@export var progress_bar: ProgressBar


func _ready() -> void:
	loading_resources.clear()
	completed_resources.clear()
	for path: String in resource_paths:
		if not ResourceLoader.exists(path):
			resource_failed.emit(path)
			continue
		var err: Error = ResourceLoader.load_threaded_request(path)
		if err:
			push_error("Error loading resource \"%s\": %s" % [path, error_string(err)])
			resource_failed.emit(path)
			continue
		loading_resources[path] = 0.0
	if loading_resources.is_empty():
		set_process(false)
	else:
		set_process(true)
	_update_progress()


func _process(_delta: float) -> void:
	_update_progress()


func _update_progress() -> void:
	var current_load: float = float(completed_resources.size())
	for path: String in loading_resources.keys():
		var progress_ref: Array = []
		var status: ResourceLoader.ThreadLoadStatus
		status = ResourceLoader.load_threaded_get_status(path, progress_ref)
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			var msg: String = "No message available"
			if status == ResourceLoader.THREAD_LOAD_FAILED:
				msg = "Thread load failed"
			elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				msg = "Invalid resource"
			printerr("Error loading resource \"%s\": %s" % [path, msg])
			loading_resources.erase(path)
			resource_failed.emit(path)
			continue
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			loading_resources.erase(path)
			completed_resources.set(path, ResourceLoader.load_threaded_get(path))
			resource_loaded.emit(path)
			if cache_resources:
				ResourceCache.cache_resource(completed_resources[path])
			continue
		current_load += progress_ref[0]
	if not progress_bar:
		return
	var total_load: float = float(loading_resources.size()) + current_load
	progress_bar.max_value = total_load
	progress_bar.value = current_load
	if loading_resources.is_empty():
		finished.emit()
		set_process(false)
