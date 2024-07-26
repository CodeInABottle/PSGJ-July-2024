extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	var npc: BaseNPC = agent
	npc.pick_point(world_state)

func apply_effects(world_state: Dictionary) -> void:
	world_state["has_wander_point"] = true

func apply_expected_effects(world_state: Dictionary) -> void:
	pass # Replace with function body
