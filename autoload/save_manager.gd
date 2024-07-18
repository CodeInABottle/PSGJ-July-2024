extends Node

var secret_saves: Dictionary = {}

func _ready() -> void:
	create_secret_saves()

func create_secret_saves() -> void:
	pass

func is_save_string_secret(save_string: String) -> bool:
	if secret_saves.keys().has(save_string):
		return true
	else:
		return false

func _process(_delta: float) -> void:
	pass

func load_overworld_database() -> void:
	pass

func generate_scene_from_string(save_string: String) -> void:
	if is_save_string_secret(save_string):
		pass # load secret level
	elif Marshalls.base64_to_variant(save_string) is Dictionary:
		#var save_dictionary: Dictionary = Marshalls.base64_to_variant(save_string)
		pass
