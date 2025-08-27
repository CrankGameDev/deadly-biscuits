class_name ChocChipBiscuit
extends Biscuit

const MAX_CHOC_CHIPS: int = 14

@export_range(0, MAX_CHOC_CHIPS)
var choc_chip_count: int = MAX_CHOC_CHIPS

@export_range(0, 8, 1, "or_greater")
var bug_count: int = 0

@onready var model: Node3D = %Model
@onready var bug_particles: GPUParticles3D = %BugParticles


func _ready() -> void:
	# Handle spawn settings.
	if spawn_settings.has("choc_chip_count"):
		choc_chip_count = spawn_settings.get("choc_chip_count")
	elif spawn_settings.has("choc_chip_min") and spawn_settings.has("choc_chip_max"):
		choc_chip_count = randi_range(spawn_settings.get("choc_chip_min"), spawn_settings.get("choc_chip_max"))
	if spawn_settings.has("bug_count"):
		bug_count = spawn_settings.get("bug_count")
	elif spawn_settings.has("bug_count_min") and spawn_settings.has("bug_count_max"):
		bug_count = randi_range(spawn_settings.get("bug_count_min"), spawn_settings.get("bug_count_max"))
	
	# Handle rendering chocolate chips.
	var indices: Array = range(1, MAX_CHOC_CHIPS + 1)
	indices.shuffle()
	for i in MAX_CHOC_CHIPS - choc_chip_count:
		model.get_node(str("Chip", indices[i])).hide()
	
	# Handle rendering bugs. (Ew)
	bug_particles.amount = maxi(bug_count, 1)
	if bug_count < 1:
		bug_particles.emitting = false
		bug_particles.hide()
