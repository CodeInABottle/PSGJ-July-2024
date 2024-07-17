@tool
class_name HTNModuleBaseNode
extends HTNBaseNode

func initialize() -> void:
	super()

func get_node_name() -> String:
	return ""

func get_module_function_name() -> String:
	assert(false, "HTN Module Base Node - Requires overriding.")
	return ""

# Return value:
#	On valid: return "" (and empty string)
#	On invalid: return an error message string
func validate_self() -> String:
	return "HTN Module Base Node Default Error Message"

func load_data(_data: Dictionary) -> void:
	pass

func get_data() -> Dictionary:
	return {}
