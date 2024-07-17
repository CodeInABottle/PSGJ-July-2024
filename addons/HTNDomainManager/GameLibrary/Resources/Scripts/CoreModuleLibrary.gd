class_name HTNCoreModuleLibrary
extends RefCounted

func generate_random_number(world_state: Dictionary, node_data: Dictionary) -> void:
	if node_data["Type"] == 0:	# Int
		world_state["RNG"] = randi_range(int(node_data["MinValue"]), int(node_data["MaxValue"]))
	elif node_data["Type"] == 1:	# Float
		world_state["RNG"] = randf_range(float(node_data["MinValue"]), float(node_data["MaxValue"]))
	else:	# Boolean
		world_state["RNG"] = bool(randi_range(0, 1))
