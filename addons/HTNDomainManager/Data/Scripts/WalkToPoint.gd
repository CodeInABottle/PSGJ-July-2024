extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	var npc: BaseNPC = agent
	agent.walk_to_point(world_state)

func apply_effects(world_state: Dictionary) -> void:
	pass # Replace with function body

func apply_expected_effects(world_state: Dictionary) -> void:
	pass # Replace with function body
