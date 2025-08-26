class_name SpawnEvent
extends Resource

@export var biscuit_scene: PackedScene

@export var spawn_settings: Dictionary[String, Variant]


func spawn() -> Biscuit:
	var biscuit: Biscuit = biscuit_scene.instantiate() as Biscuit
	biscuit.spawn_settings = spawn_settings
	return biscuit


func _to_string() -> String:
	return "SpawnEvent(\"%s\":%s)" % [biscuit_scene.resource_path, spawn_settings]
