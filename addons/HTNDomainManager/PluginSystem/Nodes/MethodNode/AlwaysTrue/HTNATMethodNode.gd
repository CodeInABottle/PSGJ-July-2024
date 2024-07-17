@tool
class_name HTNMethodNodeAlwaysTrue
extends HTNMethodNode

func initialize() -> void:
	super()
	condition_data = { "AlwaysTrue": true }

func get_node_name() -> String:
	return ""

func get_node_type() -> String:
	return "Always True Method"

func validate_self() -> String:
	return ""

func get_priority() -> int:
	return -9223372036854775808

func load_data(_data: Dictionary) -> void:
	# WHO? IDC
	pass
