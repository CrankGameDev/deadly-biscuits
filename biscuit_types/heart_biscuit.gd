class_name HeartBiscuit
extends Biscuit

@export var is_evil: bool

@onready var evil_model: Node3D = %EvilModel
@onready var good_model: Node3D = %GoodModel
@onready var animation: AnimationPlayer = %Animation


func _ready() -> void:
	if spawn_settings.has("is_evil"):
		is_evil = spawn_settings.get("is_evil")
	if is_evil:
		good_model.hide()
		evil_model.show()
		animation.play("throb")
	else:
		good_model.show()
		evil_model.hide()
