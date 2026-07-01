## Contains common utilities for [Resource] loading.
class_name ResourceLoadUtil


## Asynchronously (via [signal SceneTree.process_frame]) loads a resource from the given [param path]. [br]
## The [param type_hint] and [param cache_mode] parameters may be passed in the same manner as [method ResourceLoader.load]. [br]
## The [param progress_array] parameter can be optionally used to pass in an array reference which will be updated to contain
## the resource loading progress ([code]0.0[/code] to [code]1.0[/code]) every process frame on the main thread. [br]
## Upon Resource loading finishing, this function will return the loaded [Resource] or [code]null[/code] if the loading failed. [br]
## An error may be pushed if there is an issue loading the resource.
static func load_async(
	path: String,
	type_hint: String = "",
	cache_mode: ResourceLoader.CacheMode = ResourceLoader.CACHE_MODE_REUSE,
	progress_array: Array = [],
) -> Resource:
	if ResourceLoader.has_cached(path):
		return ResourceLoader.get_cached_ref(path)
	var resource: Resource = null
	var error: Error = ResourceLoader.load_threaded_request(path, type_hint, cache_mode)
	if error:
		push_error("Error loading resource %s: %s" % [
			("\"%s\"" % path) if type_hint.is_empty() else ("\"%s\":\"%s\"" % [path, type_hint]),
			error_string(error),
		])
		return null
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path, progress_array)
	var tree: SceneTree = (Engine.get_main_loop() as SceneTree)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await tree.process_frame
		status = ResourceLoader.load_threaded_get_status(path, progress_array)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		resource = ResourceLoader.load_threaded_get(path)
	return resource
