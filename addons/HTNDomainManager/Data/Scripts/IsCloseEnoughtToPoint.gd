extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

const WANDER_STOP_DISTANCE: float = 10.0

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	var npc: BaseNPC = agent
	npc.is_close_enough_to_point(world_state)

func apply_effects(world_state: Dictionary) -> void:
	if (world_state["npc_position"] - world_state["wander_point"]).length() > WANDER_STOP_DISTANCE:
		world_state["close_enough_to_point"] = false
	else:
		world_state["close_enough_to_point"] = true
		world_state["has_wander_point"] = false

func apply_expected_effects(world_state: Dictionary) -> void:
	pass # Replace with function body
