extends CanvasLayer

@onready var checklist_items: VBoxContainer = %ChecklistItems

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for criteria in LevelManager.get_current_level().critera:
		var label : Label = Label.new()
		label.text = criteria._get_text() 
		checklist_items.add_child(label) 
