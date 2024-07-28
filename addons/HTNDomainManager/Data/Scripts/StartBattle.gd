extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

var _is_in_battle: bool = false

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	if not _is_in_battle:
		var npc: BaseNPC = agent
		npc.battle_finished.connect(on_battle_finished.bind(HTN_finished_op_callback, npc))
		
		_is_in_battle = true
		npc.start_battle(world_state)

func on_battle_finished(callback: Callable, npc:BaseNPC):
	_is_in_battle = false
	npc.battle_finished.disconnect(on_battle_finished)
	callback.call()

func apply_effects(world_state: Dictionary) -> void:
	pass # Replace with function body

func apply_expected_effects(world_state: Dictionary) -> void:
	pass # Replace with function body
