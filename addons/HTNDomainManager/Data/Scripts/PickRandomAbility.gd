extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	var battle_agent: BattlefieldAIEntity = (agent as BattlefieldAIEntity)
	var ability_idx: int = world_state["rng"] % world_state["ability_count"]
	var current_ap: int = battle_agent.activate_ability(ability_idx)
	world_state["ap"] = current_ap

func apply_effects(world_state: Dictionary) -> void:
	pass # Replace with function body

func apply_expected_effects(world_state: Dictionary) -> void:
	var ability_idx: int = world_state["rng"] % world_state["ability_count"]
	world_state["ap"] -= world_state["ap_required_" + str(ability_idx)]
