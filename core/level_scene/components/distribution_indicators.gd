class_name DistributionIndicators
extends Node3D

enum Status {
	## The next batch is being prepared and the
	## player has some time before it will be distributed.
	BATCH_PREPARING,
	
	## The next batch has been prepared and will be distributed soon.
	BATCH_PREPARED,
	
	## The next batch is being deployed.
	BATCH_DEPLOYING,
	
	## The distributor is inactive and batches are not being prepared.
	INACTIVE = -1,
}


@export
var status: Status = Status.INACTIVE: set = set_status

@onready var green_material: StandardMaterial3D = %GreenIndicator.material_override
@onready var yellow_material: StandardMaterial3D = %YellowIndicator.material_override
@onready var red_material: StandardMaterial3D = %RedIndicator.material_override

var tweens: Array[Tween]


func _init() -> void:
	tweens.resize(3)


func _ready() -> void:
	for i: int in 3:
		_set_indicator(i, 0.0)
	_update_indicators()


func set_status(value: Status) -> void:
	status = value
	_update_indicators()


func _update_indicators() -> void:
	for i: int in 3:
		var target_strength: float = 4.0 if int(status) == i else 0.0
		_update_indicator(i, target_strength)


func _set_indicator(index: int, strength: float) -> void:
	var material: StandardMaterial3D
	var color: Color
	if index == 0:
		material = red_material
		color = Color(strength, 0, 0)
	elif index == 1:
		material = yellow_material
		color = Color(strength, strength, 0)
	elif index == 2:
		material = green_material
		color = Color(0, strength, 0)
	else:
		push_error("Invalid index '%d'" % index)
	if not material:
		return
	material.albedo_color = color


func _update_indicator(index: int, strength: float, duration: float = 0.5) -> void:
	var material: StandardMaterial3D
	var color: Color
	var tween: Tween = tweens.get(index)
	if index == 0:
		material = red_material
		color = Color(strength, 0, 0)
	elif index == 1:
		material = yellow_material
		color = Color(strength, strength, 0)
	elif index == 2:
		material = green_material
		color = Color(0, strength, 0)
	else:
		push_error("Invalid index '%d'" % index)
	if not material:
		return
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tweens[index] = tween
	if strength > 0.0:
		tween.set_ease(Tween.EASE_IN)
	else:
		tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(material, ^"albedo_color", color, duration)
