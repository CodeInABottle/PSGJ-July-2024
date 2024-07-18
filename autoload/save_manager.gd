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
		set_player_position(current_save_dictionary)

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

func set_player_position(save_dictionary: Dictionary) -> void:
	var player_nodes = get_tree().get_nodes_in_group("player")
	if not player_nodes.is_empty() and save_dictionary.keys().has("position"):
		var player: CharacterBody2D = player_nodes[0]
		player.set_global_position(save_dictionary["position"])
	else:
		print("failed to load position")

func generate_save_string() -> String:
	var save_dictionary: Dictionary = {}
	var player_nodes = get_tree().get_nodes_in_group("player")
	
	if not player_nodes.is_empty():
		var player: CharacterBody2D = player_nodes[0]
		save_dictionary["position"] = player.get_global_position()
		var save_string: String = Marshalls.variant_to_base64(save_dictionary)
		
		return save_string
	else:
		return "FAILED"
