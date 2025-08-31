extends CanvasLayer

@onready var checklist_items: VBoxContainer = %ChecklistItems
@onready var clipboard_area: Control = %ClipboardArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for criteria in LevelManager.get_current_level().critera:
		var label : Label = Label.new()
		label.text = criteria._get_text() 
		checklist_items.add_child(label) 


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_criteria"):
		visible = !visible 
		get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if (
		visible and event is InputEventMouseButton and event.pressed 
		and not clipboard_area.get_global_rect().has_point(event.global_position)
	):
		# Hide the clipboard when the mouse is clicked outside of its area.
		hide()
