class_name SpawnEvent
extends Resource

@export_file("*.tscn", "*.scn")
var biscuit_scene_path: String

@export var spawn_settings: Dictionary[String, Variant]

var biscuit_scene: PackedScene


func spawn() -> Biscuit:
	if not biscuit_scene:
		print("Loading biscuit scene: ", biscuit_scene_path)
		biscuit_scene = load(biscuit_scene_path)
	var biscuit: Biscuit = biscuit_scene.instantiate() as Biscuit
	biscuit.spawn_settings = spawn_settings
	return biscuit


func _to_string() -> String:
	return "SpawnEvent(\"%s\":%s)" % [biscuit_scene_path, spawn_settings]
