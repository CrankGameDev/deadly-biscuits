extends Node

signal back_button_pressed

@onready var apply_button: Button = %ApplyButton
@onready var revert_button: Button = %RevertButton
@onready var restore_defaults_button: Button = %RestoreDefaultsButton

@onready var unsaved_changes_label: Label = %UnsavedChangesLabel
@onready var back_button_confirmation_dialog: ConfirmationDialog = %BackButtonConfirmationDialog


func _ready() -> void:
	GameSettings.audio_level_changed.connect(_update.unbind(2))
	_update()


func _on_apply_button_pressed() -> void:
	GameSettings.save_to_file()
	_update()


func _on_revert_button_pressed() -> void:
	GameSettings.revert_to_save()
	_update()


func _on_restore_defaults_confirmed() -> void:
	GameSettings.restore_all_defaults()
	_update()


func _update() -> void:
	var has_unsaved_changes: bool = GameSettings.has_unsaved_changes()
	apply_button.disabled = not has_unsaved_changes
	revert_button.disabled = not has_unsaved_changes
	unsaved_changes_label.visible = has_unsaved_changes
	restore_defaults_button.disabled = GameSettings.are_all_default()


func _on_back_button_pressed() -> void:
	if GameSettings.has_unsaved_changes():
		back_button_confirmation_dialog.show()
	else:
		back_button_pressed.emit()


func _on_back_button_confirmed() -> void:
	if GameSettings.has_unsaved_changes():
		GameSettings.revert_to_save()
	back_button_pressed.emit()
