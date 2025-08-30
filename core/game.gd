extends Node3D


@onready var checklist: CanvasLayer = $Checklist
var paused = false 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		checklistMenu()
#bring up screen with checklist
func checklistMenu(): 
	if paused:
		checklist.hide() 
		#Engine.time_scale = 1
	else:
		checklist.show()
		#Engine.time_scale = 0
		
	paused = !paused 	
		
		
	
