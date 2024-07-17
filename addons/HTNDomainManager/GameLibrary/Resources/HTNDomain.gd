class_name HTNDomain
extends Resource

@export var root_key: StringName

# { task_key (StringName) : task_name (String) }
@export var task_map: Dictionary

# { domain_key (StringName) : domain_name (String) }
@export var domain_map: Dictionary

# [ (quit_key (StringName))... ]
@export var quits: Array[StringName] = []

# {splitter_node_key (StringName) : [(method_node_key: (StringName))...] *sorted high -> low }
@export var splits: Dictionary

#	{
#		method_node_key (StringName) : {
#			"method_data" (WorldState => String): {
#				"CompareID": (int),
#				"RangeID": (int),
#				"SingleID": (int),
#				"Value": any,
#				"RangeInclusivity": [boolean, boolean]
#			},
#			"task_chain": [(task_name: StringName)...]
#		}
#	}
@export var methods: Dictionary

# { effect_node_key (StringName) : { "world_state_key" : {"type_id": int, "value": any} } }
@export var effects: Dictionary

# { module_node_key (StringName) : ["function_name", { ..module_data.. }] }
@export var modules: Dictionary
