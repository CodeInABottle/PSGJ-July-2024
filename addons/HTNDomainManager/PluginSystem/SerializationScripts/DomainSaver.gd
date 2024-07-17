@tool
class_name HTNDomainSaver
extends Node

const DOMAIN_PATH := "res://addons/HTNDomainManager/Data/Domains/"
const GRAPH_SAVE_PATH := "res://addons/HTNDomainManager/Data/GraphSaves/"

static func save(notification_handler: HTNNotificaionHandler, domain_graph: HTNDomainGraph) -> bool:
	var domain_file: HTNDomain = _save_to_domain_resource(domain_graph)
	return _save_to_graph_file(notification_handler, domain_graph, domain_file)

static func _save_to_domain_resource(domain_graph: HTNDomainGraph) -> HTNDomain:
	var domain_resource: HTNDomain = null
	if domain_resource == null:
		if FileAccess.file_exists(DOMAIN_PATH + domain_graph.domain_name + ".tres"):
			domain_resource = ResourceLoader.load(DOMAIN_PATH + domain_graph.domain_name + ".tres")
		else:
			domain_resource = HTNDomain.new()

	domain_resource["root_key"] = domain_graph.root_key

	# Write task key name pairs
	var task_key_name_pairs: Dictionary = domain_graph.get_task_key_name_pair()
	# Reset
	domain_resource["task_map"].clear()
	for node_key: StringName in task_key_name_pairs.keys():
		if node_key in domain_resource["task_map"]: continue
		domain_resource["task_map"][node_key] = task_key_name_pairs[node_key]
	# Write domain key name pairs
	var domain_key_name_pairs: Dictionary = domain_graph.get_domain_key_name_pair()
	domain_resource["domain_map"].clear()
	for node_key: StringName in domain_key_name_pairs.keys():
		if node_key in domain_resource["domain_map"]: continue
		domain_resource["domain_map"][node_key] = domain_key_name_pairs[node_key]
	domain_resource["quits"] = domain_graph.get_quits()
	domain_resource["splits"] = _gather_split_data(domain_graph)
	domain_resource["effects"] = _gather_effect_data(domain_graph)
	domain_resource["methods"] = _gather_method_data(domain_graph)
	domain_resource["modules"] = _gather_module_data(domain_graph)

	# Send the file to be saved
	return domain_resource

static func _save_to_graph_file(notification_handler: HTNNotificaionHandler, domain_graph: HTNDomainGraph,
		domain_resource: HTNDomain) -> bool:
	var graph_save_path: String = GRAPH_SAVE_PATH + domain_graph.domain_name + ".tres"
	var graph_save: HTNGraphSave = null
	if FileAccess.file_exists(graph_save_path):
		graph_save = load(graph_save_path)
		graph_save["connections"].clear()
		graph_save["node_types"].clear()
		graph_save["node_positions"].clear()
		graph_save["node_data"].clear()
	if graph_save == null:
		graph_save = HTNGraphSave.new()

	graph_save["root_key"] = domain_graph.root_key
	graph_save["connections"] = domain_graph.get_connection_list()
	for node_key: StringName in domain_graph.nodes.keys():
		graph_save["node_types"][node_key] = domain_graph.get_node_type(node_key)
		graph_save["node_positions"][node_key] = (domain_graph.nodes[node_key] as HTNBaseNode).position_offset
		graph_save["node_data"][node_key] = domain_graph.get_node_data(node_key)

	var domain_path: String = DOMAIN_PATH + domain_graph.domain_name + ".tres"
	if ResourceSaver.save(domain_resource, domain_path) != OK:
		notification_handler.send_error("Building New Domain: '"+domain_graph.domain_name+"' Failed")
		return false

	if ResourceSaver.save(graph_save, graph_save_path) != OK:
		notification_handler.send_error("Building Graph Save: '"+domain_graph.domain_name+"' Failed")
		DirAccess.remove_absolute(domain_path)
		return false

	return true

static func _gather_effect_data(domain_graph: HTNDomainGraph) -> Dictionary:
	var effect_data: Dictionary = {}
	for node_key: StringName in domain_graph.nodes.keys():
		var node: HTNBaseNode = domain_graph.nodes[node_key]
		if node is HTNApplicatorNode:
			#node.effect_data = { "WorldState" : { "TypeID", "Value" } }
			effect_data[node_key] = node.effect_data
	return effect_data

static func _gather_split_data(domain_graph: HTNDomainGraph) -> Dictionary:
	var split_data: Dictionary = {}
	for node_key: StringName in domain_graph.nodes.keys():
		var node: HTNBaseNode = domain_graph.nodes[node_key]
		if node is HTNSplitterNode or node is HTNRootNode:
			var connected_node_keys: Array[StringName]\
				= HTNConnectionHandler.get_connected_nodes_from_output(domain_graph, node_key)

			connected_node_keys.sort_custom(
				func(lhs: StringName, rhs: StringName) -> bool:
					var node_a: HTNMethodNode = domain_graph.nodes[lhs]
					var node_b: HTNMethodNode = domain_graph.nodes[rhs]

					return node_a.get_priority() > node_b.get_priority()
			)

			split_data[node_key] = connected_node_keys
	return split_data

static func _gather_method_data(domain_graph: HTNDomainGraph) -> Dictionary:
	var method_data: Dictionary = {}
	for node_key: StringName in domain_graph.nodes.keys():
		var node: HTNBaseNode = domain_graph.nodes[node_key]
		if node is HTNMethodNode:
			method_data[node_key] = {
				#node.condition_data = {
					#"WorldState" = { "CompareID", "RangeID", "SingleID", "Value", "RangeInclusivity" }
				#}
				"method_data": node.condition_data,
				"task_chain": domain_graph.get_every_node_til_compound(node_key)
			}
	return method_data

static func _gather_module_data(domain_graph: HTNDomainGraph) -> Dictionary:
	var module_data: Dictionary = {}
	for node_key: StringName in domain_graph.nodes.keys():
		var node: HTNBaseNode = domain_graph.nodes[node_key]
		# { module_node_key (StringName) : ["function_name", { ..module_data.. }] }
		if node is HTNModuleBaseNode:
			module_data[node_key] = [
				(node as HTNModuleBaseNode).get_module_function_name(),
				(node as HTNModuleBaseNode).get_data()
			]
	return module_data
