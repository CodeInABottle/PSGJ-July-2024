extends Node

var pause_menu: Control
var fader_controller: CanvasLayer

func _ready() -> void:
	fader_controller = get_node_or_null("/root/Main/FaderLayer")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("escape"):
			toggle_pause()

func toggle_pause() -> void:
	if pause_menu:
		if LevelManager.is_paused():
			LevelManager.enable_world_node()
			pause_menu.hide()
			fader_controller.fade_from_translucent()
		else:
			LevelManager.disable_world_node()
			pause_menu.show()
			fader_controller.fade_to_translucent()
			
	
