## An autoload Node which manages game settings.
##
## The GameSettings global represents the current (as set in controls)
## values of various game settings. [br]
## Settings are not applied to the game until [method apply] is invoked. [br]
## The [method queue_apply] function can be used to apply changes at once in the next process frame. [br]
## All settings are automatically loaded and applied once upon game start via this singleton. [br]
## [br]
## Settings which have been changed are not saved until [method save_to_file] is used. [br]
## Settings can also be loaded from the save file via [method load_from_file],
## however if reverting unsaved changes is desired then the [method revert_to_save] method
## should be more efficient for this use-case. [br]
## Settings can be restored to default values via [method restore_default], or all
## at once via [method restore_all_defaults]. [br]
## [br]
## The [method has_unapplied_changed] function can be used to check for any changes
## which have yet to be applied to the game. [br]
## The [method has_unsaved_changes] function can be used to check for any changes
## which haven't been saved to the file yet. [br]
## The [method are_all_default] function can be used to check whether all current
## settings values are default where applicable.
@tool
extends Node

## A signal emitted when an audio level setting for the given [param bus] has changed to a given [param new_level].
signal audio_level_changed(bus: StringName, new_level: float)

@export_group("Sound Levels", "sound_level_")

# TODO: Might be worth considering making these properties dynamic
#	and have them pull from the AudioServer.
# 	This would lose convenient completions though.

@export_storage
var sound_level_master: float = 1.0:
	set(value):
		if sound_level_master == value:
			return
		_has_unapplied_changes = true
		_unsaved_values.get_or_add(&"sound_level_master", sound_level_master)
		sound_level_master = value
		audio_level_changed.emit(&"Master", value)

@export_storage
var sound_level_sfx: float = 1.0:
	set(value):
		if sound_level_sfx == value:
			return
		_has_unapplied_changes = true
		_unsaved_values.get_or_add(&"sound_level_sfx", sound_level_sfx)
		sound_level_sfx = value
		audio_level_changed.emit(&"SFX", value)

@export_storage
var sound_level_ambience: float = 1.0:
	set(value):
		if sound_level_ambience == value:
			return
		_has_unapplied_changes = true
		_unsaved_values.get_or_add(&"sound_level_ambience", sound_level_ambience)
		sound_level_ambience = value
		audio_level_changed.emit(&"Ambience", value)


# Maps groups/sections to the list of settings underneath them.
# This is a two-layer dictionary which first maps sections to dictionaries
# of properties in those sections.
# These "section dictionaries" map unprefixed "keys" to full property names.
# Eg. "Sound Levels/" -> "master" -> "sound_level_master"
# This provides a convenient way to look up object property names in reverse
# from settings file sections and keys.
var _group_settings: Dictionary[StringName, Dictionary]

# Maps property names to groups they belong to.
var _settings_groups: Dictionary[StringName, StringName]

# Maps property names to unprefixed "keys".
# Keys will exclude any prefix belonging to the group of the property.
# Properties are stored in the settings using these keys.
var _settings_keys: Dictionary[StringName, StringName]

# Stores previous settings property values when changes are made without saving.
var _unsaved_values: Dictionary[StringName, Variant]

# Represents the settings config file in memory.
var config_file: ConfigFile

# Stores the path to the settings config file in the file system.
var config_file_path: String

var _has_unapplied_changes: bool = true

# Stores whether a settings application action was queued for the next frame.
# This can batch settings application and avoid triggering redundant applications
# when multiple settings are changed at once.
var _apply_queued: bool = false


func _init() -> void:
	const BASE_TYPE: StringName = &"Node"
	var base_properties: Dictionary[StringName, bool] = {&"script": true}
	for property: Dictionary in ClassDB.class_get_property_list(BASE_TYPE):
		if property.usage & PROPERTY_USAGE_STORAGE:
			base_properties[property.name] = true
	var current_group: String
	var current_group_prefix: String
	var current_subgroup: String
	var current_prefix: String
	for property: Dictionary in get_property_list():
		if property.usage & PROPERTY_USAGE_GROUP:
			current_group = property.name
			current_group_prefix = property.hint_string
			current_subgroup = ""
			current_prefix = current_group_prefix
		elif property.usage & PROPERTY_USAGE_SUBGROUP:
			current_subgroup = property.name
			current_prefix = current_group_prefix + property.hint_string
		if not property.usage & PROPERTY_USAGE_STORAGE or base_properties.has(property.name):
			continue
		
		var property_name: StringName = property.name
		var property_group: StringName = current_group.path_join(current_subgroup)
		var no_prefix: StringName = property_name.trim_prefix(current_prefix)
		
		_settings_keys[property_name] = no_prefix
		_settings_groups[property_name] = property_group
		_group_settings.get_or_add(property_group, {})[no_prefix] = property_name


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	config_file = ConfigFile.new()
	config_file_path = ProjectSettings.get_setting_with_override(&"application/config/settings_file")
	var error: Error = load_from_file()
	if error:
		save_to_file()
	set_process(_apply_queued)


func _ready() -> void:
	apply()


func _process(_delta: float) -> void:
	if _apply_queued:
		_apply_queued = false
		apply()
	set_process(false)


func _property_can_revert(property: StringName) -> bool:
	if (
		property == &"sound_level_master"
		or property == &"sound_level_sfx"
		or property == &"sound_level_ambience"
	):
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if (
		property == &"sound_level_master"
		or property == &"sound_level_sfx"
		or property == &"sound_level_ambience"
	):
		return 1.0
	return null


## Applies all settings, making them take effect on the game.
func apply() -> void:
	# Apply audio settings
	var master_bus: int = AudioServer.get_bus_index(&"Master")
	var sfx_bus: int = AudioServer.get_bus_index(&"SFX")
	var ambience_bus: int = AudioServer.get_bus_index(&"Ambience")
	AudioServer.set_bus_volume_linear(master_bus, sound_level_master)
	AudioServer.set_bus_volume_linear(sfx_bus, sound_level_sfx)
	AudioServer.set_bus_volume_linear(ambience_bus, sound_level_ambience)
	_has_unapplied_changes = false


## Saves all settings to the save file.
func save_to_file() -> Error:
	for section: StringName in _group_settings:
		for setting: StringName in _group_settings[section]:
			var value: Variant = get(_group_settings[section][setting])
			config_file.set_value(section, setting, value)
	_unsaved_values.clear()
	return config_file.save(config_file_path)


## Loads all settings from the save file.
func load_from_file() -> Error:
	var error: Error = config_file.load(config_file_path)
	for section: StringName in config_file.get_sections():
		var section_props: Dictionary = _group_settings.get(section, {})
		for setting: StringName in config_file.get_section_keys(section):
			var value: Variant = config_file.get_value(section, setting)
			var property_name: StringName = section_props.get(setting, &"")
			if not property_name.is_empty():
				set(property_name, value)
	_unsaved_values.clear()
	return error


## Reverts all unsaved settings to their previous values.
func revert_to_save() -> void:
	for property: StringName in _unsaved_values:
		set(property, _unsaved_values[property])
	_unsaved_values.clear()


## Restores all properties to their default values where applicable.
func restore_all_defaults() -> void:
	for property: StringName in _settings_groups:
		restore_default(property)


## Restores the given [param property] to its default value, if it has one.
func restore_default(property: StringName) -> void:
	if not property_can_revert(property):
		return
	var default: Variant = property_get_revert(property)
	var current: Variant = get(property)
	if current == default:
		return
	set(property, default)


## Returns a list of all "settings" properties by property name.
func get_settings_property_list() -> PackedStringArray:
	return PackedStringArray(_settings_groups.keys())


## Queues one invocation of the [method apply] method on the next process frame.
func queue_apply() -> void:
	_apply_queued = true
	set_process(true)


## Returns whether any settings have changes which have not been saved.
func has_unsaved_changes() -> bool:
	return not _unsaved_values.is_empty()


## Returns whether any settings are changed from default values.
func are_all_default() -> bool:
	for property: StringName in _settings_groups:
		if property_can_revert(property) and get(property) != property_get_revert(property):
			return false
	return true


## Returns whether any settings have been changed without [method apply] having been called yet.
func has_unapplied_changes() -> bool:
	return _has_unapplied_changes
