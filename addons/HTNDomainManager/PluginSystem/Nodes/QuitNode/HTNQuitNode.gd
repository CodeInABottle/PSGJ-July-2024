@tool
class_name HTNQuitNode
extends HTNBaseNode

func get_node_name() -> String:
	return "Quit Node"

func get_node_type() -> String:
	return "Quit"

func validate_self() -> String:
	return ""
