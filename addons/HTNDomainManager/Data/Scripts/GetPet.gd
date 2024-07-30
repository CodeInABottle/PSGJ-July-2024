extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

var _is_being_pet: bool = false

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	var npc: BaseNPC = agent
	if not _is_being_pet:
		npc.petting_finished.connect(on_pet_finished.bind(HTN_finished_op_callback, npc))
	npc.get_pet(world_state)
	
func on_pet_finished(callback: Callable, npc:BaseNPC):
	_is_being_pet = false
	npc.petting_finished.disconnect(on_pet_finished)
	callback.call()

func apply_effects(world_state: Dictionary) -> void:
	pass # Replace with function body

func apply_expected_effects(world_state: Dictionary) -> void:
	pass # Replace with function body
