class_name SaveData
extends Resource

@export var current_level: int = 1 :
	set(value):
		current_level = value
		emit_changed()
