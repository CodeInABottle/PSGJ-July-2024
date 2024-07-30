extends Control

signal closed

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var master_precentage: Label = %MasterPrecentage
@onready var music_precentage: Label = %MusicPrecentage
@onready var sfx_precentage: Label = %SFXPrecentage

func _ready() -> void:
	_update_volume_sliders()

func _update_volume_sliders() -> void:
	master_slider.value = remap(AudioServer.get_bus_volume_db(0), -40.0, 0.0, 0.0, 100.0)
	sfx_slider.value = remap(AudioServer.get_bus_volume_db(1), -40.0, 0.0, 0.0, 100.0)
	music_slider.value = remap(AudioServer.get_bus_volume_db(2), -40.0, 0.0, 0.0, 100.0)
	master_precentage.text = _get_volume_str(master_slider.value)
	sfx_precentage.text = _get_volume_str(sfx_slider.value)
	music_precentage.text = _get_volume_str(music_slider.value)

func _get_volume_str(value: float) -> String:
	if value <= 0:
		return "Muted"
	elif value >= 100:
		return "Max"
	else:
		return str(int(value)) + "%"

func _on_sfx_slider_visibility_changed() -> void:
	if visible and is_node_ready():
		_update_volume_sliders()

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, remap(value, 0.0, 100.0, -40.0, 0.0))
	master_precentage.text = _get_volume_str(value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, remap(value, 0.0, 100.0, -40.0, 0.0))
	music_precentage.text = _get_volume_str(value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, remap(value, 0.0, 100.0, -40.0, 0.0))
	sfx_precentage.text = _get_volume_str(value)

func _on_close_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	closed.emit()
