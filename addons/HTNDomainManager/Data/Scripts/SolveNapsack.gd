extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	var battle_agent: BattlefieldAIEntity = (agent as BattlefieldAIEntity)
	var ability_chain: Array[int] = battle_agent.get_ability_chain()

	# Check if any abilities can be used
	if ability_chain.is_empty():
		print("No other abilities can be used. Remaining AP: ", battle_agent._alchemy_points)
		HTN_finished_op_callback.call()
		return

	# Activate those abilities
	for ability_idx: int in ability_chain:
		await battle_agent.activate_ability(ability_idx)
		await battle_agent.ability_finished
	HTN_finished_op_callback.call()

func apply_effects(world_state: Dictionary) -> void:
	pass # Replace with function body

func apply_expected_effects(world_state: Dictionary) -> void:
	pass # Replace with function body
