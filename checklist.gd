extends CanvasLayer

@onready var clipboard_area: Control = %ClipboardArea
@onready var checklist_item_label: Label = %ChecklistItemLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var checklist_text: String = ""
	
	for criteria in LevelManager.get_active_level().critera:
		checklist_text += "\n+ " + criteria._get_text()
	checklist_item_label.text = checklist_text


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
