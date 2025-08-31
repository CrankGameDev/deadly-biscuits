## A singleton node which manages scene changes with a listenable signal
## and maintains a list of scene file paths.
##
## The SceneManager should be used in place of [SceneTree] methods
## which change or reload the current scene [br]
## It wraps around them to provide additional functionality making scene changes
## observable through signals as well as storing parameters ([member scene_params])
## passed in to scene transition requests.
extends Node

## A signal emitted when the [member SceneTree.current_scene] is reset
## in any manner, including changing scenes or reloading the current scene. [br]
## This only accounts for changes caused by the SceneManager.
signal scene_reset

## A signal emitted when a scene change is requested. [br]
## This signal does not guarantee the validity of the quested scene change.
signal scene_changing(new_scene_path: String, old_scene_path: String)

## A signal emitted when the scene has been changed.
signal scene_changed(new_scene_path: String, old_scene_path: String)

## A signal emitted when the current scene is reloaded.
signal scene_reloaded


## A helper function to retrieve the scene file path of a given node, if it is available.
static func get_node_scene_path(node: Node) -> String:
	if not node or not is_instance_valid(node):
		return ""
	if node.owner:
		node = node.owner
	return node.scene_file_path


## A dictionary containing any parameters passed in to the currently loaded scene. [br]
## This will be the value of the last [code]params[/code] dictionary
## passed during a successful scene transition call.
var scene_params: Dictionary = {}


## Changes the current scene to a scene located at the given [param path]. [br]
## Additionally, a dictionary of [member params] may be passed to be stored under this node.
func change_scene_to_file(path: String, params: Dictionary = {}) -> Error:
	await get_tree().process_frame
	var old_path: String = get_node_scene_path(get_tree().current_scene)
	scene_changing.emit(path, get_tree().current_scene.scene_file_path)
	var error: Error = get_tree().change_scene_to_file(path)
	if not error:
		await get_tree().node_added
		scene_params = params
		scene_changed.emit(path, old_path)
		scene_reset.emit()
	return error


## Changes the current scene to the given [param packed_scene]. [br]
## Additionally, a dictionary of [member params] may be passed to be stored under this node.
func change_scene_to_packed(packed_scene: PackedScene, params: Dictionary = {}) -> Error:
	await get_tree().process_frame
	var old_path: String = get_node_scene_path(get_tree().current_scene)
	var new_path: String = packed_scene.resource_path
	scene_changing.emit(new_path, get_tree().current_scene.scene_file_path)
	scene_params = params
	var error: Error = get_tree().change_scene_to_packed(packed_scene)
	if not error:
		await get_tree().node_added
		scene_changed.emit(new_path, old_path)
		scene_reset.emit()
	return error


## Wraps around [method SceneTree.reload_current_scene]. [br]
## Maintains existing scene parameters and emits only the [signal scene_reset] signal.
func reload_current_scene() -> Error:
	await get_tree().process_frame
	var error: Error = get_tree().reload_current_scene()
	if not error:
		scene_reloaded.emit()
		await get_tree().node_added
		scene_reset.emit()
	return error


## Quits the game, akin to [method SceneTree.quit] but with [constant Node.NOTIFICATION_WM_CLOSE_REQUEST]
## propagated down the SceneTree. [br]
## As with the SceneTree quit method, an [param exit_code] can be provided. [br]
## Additionally, you can use the [param skip_notification] to opt to skip close request notification propagation.
func quit(exit_code: int = 0, skip_notification: bool = false) -> void:
	if not skip_notification:
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit(exit_code)
