extends Node

var secret_saves: Dictionary = {}
var current_save_dictionary: Dictionary = {}
var load_pending: bool = false

func _ready():
	create_secret_saves()

func create_secret_saves() -> void:
	pass

func is_save_string_secret(save_string: String) -> bool:
	if secret_saves.keys().has(save_string):
		return true
	else:
		return false

func _process(delta):
	pass

func load_overworld_database() -> void:
	pass

func attempt_load() -> void:
	if load_pending:
		load_pending = false
		PlayerStats.load_data.call_deferred(current_save_dictionary)

func generate_scene_from_string(save_string: String) -> void:
	if is_save_string_secret(save_string):
		pass # load secret level
	elif Marshalls.base64_to_variant(save_string) is Dictionary:
		var save_dictionary: Dictionary = Marshalls.base64_to_variant(save_string)
		current_save_dictionary = save_dictionary
		load_pending = true
		get_tree().change_scene_to_file("res://areas/area_0.tscn")
	else:
		get_tree().change_scene_to_file("res://areas/area_0.tscn")

func generate_save_string() -> String:
	var save_dictionary: Dictionary = PlayerStats.get_save_data()
	var save_string: String = Marshalls.variant_to_base64(save_dictionary)
	
	return save_string
