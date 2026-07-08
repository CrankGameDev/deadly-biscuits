@tool
class_name VolumeSliderControl
extends HBoxContainer

const RELOAD_ICON_PATH: String = "uid://csolskv8wqgp5"
const EMPTY_IMAGE_PATH: String = "uid://bu7ct2bcm6tti"

signal value_changed(value: float)

## An [AudioStream] to play as a sample for this control. [br]
## This will use the assigned bus by default.
@export var audio_sample: AudioStream: set = set_audio_sample

## The audio sample volume offset in decibels. [br]
## See [member AudioStreamPlayer.volume_db]
@export_range(-80.0, 24.0, 0.05, "suffix:dB")
var audio_sample_volume: float = 0.0: set = set_audio_sample_volume

@export var play_sample_on_change: bool = true

@export var update_on_change: bool = true

@export_group("Functions", "function_")

var audio_bus: StringName = &"Master": set = set_audio_bus
var audio_bus_index: int = 0
var settings_property: StringName

var revert_button: BaseButton
var slider: HSlider
var audio_sample_player: AudioStreamPlayer

var slider_value: float = 1.0: get = get_slider_value, set = set_slider_value

var _is_pushing_to_settings: bool = false


func _init() -> void:
	revert_button = TextureButton.new()
	revert_button.ignore_texture_size = true
	revert_button.custom_minimum_size = Vector2(24.0, 24.0)
	revert_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	revert_button.texture_normal = load(RELOAD_ICON_PATH)
	revert_button.texture_disabled = load(EMPTY_IMAGE_PATH)
	revert_button.pressed.connect(_on_revert_pressed)
	add_child(revert_button, false, Node.INTERNAL_MODE_FRONT)
	
	slider = HSlider.new()
	slider.max_value = 2.0
	slider.step = 0.05
	slider.value = 1.0
	slider.tick_count = 21
	slider.ticks_on_borders = true
	slider.custom_minimum_size.x = 256.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(_on_slider_changed)
	add_child(slider, false, Node.INTERNAL_MODE_FRONT)
	
	audio_sample_player = AudioStreamPlayer.new()
	add_child(audio_sample_player, false, Node.INTERNAL_MODE_FRONT)
	
	# Update the property list if the audio bus layout changes.
	AudioServer.bus_layout_changed.connect(property_list_changed.emit)
	# Handle bus renaming, in case the stored bus needs to be updated.
	AudioServer.bus_renamed.connect(_on_bus_renamed)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_update_audio_bus()
	_pull_from_settings()
	_update_audio_sample()
	_update_sample_volume()
	_update_revert_availability()
	GameSettings.audio_level_changed.connect(_pull_from_settings.unbind(2))


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]
	var audio_bus_list: PackedStringArray
	var bus_count: int = AudioServer.bus_count
	audio_bus_list.resize(bus_count)
	for i: int in bus_count:
		audio_bus_list[i] = AudioServer.get_bus_name(i)
	props.append({
		&"name": &"audio_bus",
		&"type": TYPE_STRING_NAME,
		&"hint": PROPERTY_HINT_ENUM,
		&"hint_string": ",".join(audio_bus_list),
		&"usage": PROPERTY_USAGE_DEFAULT,
	})
	return props


func _property_can_revert(property: StringName) -> bool:
	if property == &"audio_bus":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == &"audio_bus":
		return &"Master"
	return null


func _on_revert_pressed() -> void:
	var default_value: float = get_setting_default()
	if default_value == -1.0:
		return
	slider_value = default_value


func _on_slider_changed(value: float) -> void:
	if play_sample_on_change:
		play_sample()
	value_changed.emit(value)
	if update_on_change and not Engine.is_editor_hint():
		_push_to_settings()
	_update_revert_availability()


func set_audio_sample(value: AudioStream) -> void:
	if audio_sample == value:
		return
	audio_sample = value
	_update_audio_sample()


func set_audio_sample_volume(value: float) -> void:
	if audio_sample_volume == value:
		return
	audio_sample_volume = value
	_update_sample_volume()


func set_audio_bus(value: StringName) -> void:
	if audio_bus == value:
		return
	audio_bus = value
	_update_audio_bus()


func set_slider_value(value: float) -> void:
	value = clampf(value, 0.0, 2.0)
	if slider.value != value:
		slider.value = value


func get_slider_value() -> float:
	return slider.value


func get_setting_value() -> float:
	if settings_property:
		var result: Variant = GameSettings.get(settings_property)
		if result is float:
			return result
	return -1.0


func get_setting_default() -> float:
	if settings_property and GameSettings.property_can_revert(settings_property):
		return GameSettings.property_get_revert(settings_property)
	return -1.0


func set_setting_value(value: float) -> void:
	GameSettings.set(settings_property, value)


func play_sample() -> void:
	audio_sample_player.play()


func stop_sample() -> void:
	audio_sample_player.stop()


func _on_bus_renamed(_bus_index: int, old_name: StringName, new_name: StringName) -> void:
	if old_name == audio_bus:
		audio_bus = new_name
	_update_audio_bus()


func _update_audio_bus() -> void:
	audio_bus_index = AudioServer.get_bus_index(audio_bus)
	settings_property = StringName("sound_level_" + audio_bus.to_snake_case())
	audio_sample_player.bus = audio_bus
	_pull_from_settings()


func _update_audio_sample() -> void:
	audio_sample_player.stream = audio_sample


func _update_sample_volume() -> void:
	audio_sample_player.volume_db = audio_sample_volume


func _push_slider_value() -> void:
	slider.value = slider_value


func _update_revert_availability() -> void:
	var default_value: float = get_setting_default()
	var revert_available: bool = false
	if default_value == -1.0:
		revert_available = false
	else:
		revert_available = slider_value != default_value
	revert_button.disabled = not revert_available


func _push_to_settings() -> void:
	if Engine.is_editor_hint():
		return
	_is_pushing_to_settings = true
	set_setting_value(slider_value)
	_is_pushing_to_settings = false
	GameSettings.queue_apply()


func _pull_from_settings() -> void:
	if Engine.is_editor_hint():
		return
	if _is_pushing_to_settings:
		return
	slider_value = get_setting_value()
