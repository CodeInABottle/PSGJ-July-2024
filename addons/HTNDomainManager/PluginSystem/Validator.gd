@tool
class_name HTNGraphValidator
extends Control

#region Graph Error Messages
const EMPTY_CONNECTIONS := "There are no connections."
const NO_TASK_CONNECTIONS := "This node has no action connection(s)."
const NO_METHOD_CONNECTIONS := "This node has no method connections."
const ONE_TASK_CONNECTION_REQURIED := "This node requries 1 action connected to output."
const OVER_ONE_CONNECTION := "There are more than one connection."
const OVER_ONE_ALWAYS_TRUE_METHOD_CONNECTION := "There are more than one Method Node - Always True."
const EMPTY_FUNCTION_NAME := "Requires a function to call."
const UNDEFINED_FUNCTION_NAME := "Can't find function to call with name: "

#endregion

@export var goto_panel: HTNGoToManager

var _error_node_key: StringName = ""

func validate(domain_graph: HTNDomainGraph) -> bool:
	# Validate that there are any connections....
	# I know who you are. I put this in for you... ._.
	if not _validate_there_are_any_connections(domain_graph): return false

	if not _validate_node_data(domain_graph): return false

	# Validate each node's rules (listed above function declaration)
	if not _validate_node_connections(domain_graph): return false

	return true

func _validate_there_are_any_connections(domain_graph: HTNDomainGraph) -> bool:
	var connection_list := domain_graph.get_connection_list()

	if connection_list.is_empty():
		_send_error(domain_graph, "Domain - "+domain_graph.domain_name, domain_graph.root_key, EMPTY_CONNECTIONS)
		return false
	return true

func _validate_node_data(domain_graph: HTNDomainGraph) -> bool:
	var core_module_libs: HTNCoreModuleLibrary = HTNCoreModuleLibrary.new()
	for node_key: String in domain_graph.nodes:
		var node := (domain_graph.nodes[node_key] as HTNBaseNode)
		if node.is_queued_for_deletion(): continue

		# Get Node Identification
		var node_name := node.get_node_name()
		if node_name.is_empty():
			node_name = node_key

		# Check Module Nodes for Linked Functions
		if node is HTNModuleBaseNode:
			var function_name: String = node.get_module_function_name()
			if function_name.is_empty():
				_send_error(domain_graph, node_name, node_key, EMPTY_FUNCTION_NAME)
				return false
			if not core_module_libs.has_method(function_name):
				_send_error(
					domain_graph, node_name, node_key,
					UNDEFINED_FUNCTION_NAME + function_name
				)
				return false

		# Check Standard Node Validation
		var error_message := node.validate_self()
		if not error_message.is_empty():
			_send_error(domain_graph, node_name, node_key, error_message)
			return false
	return true

# Validate each node's rules
#	- Input:
#		- Quit Node:
#			- At least 1 connection
#		- Compound Node:
#			- At least 1 action connection
#		- Primitive Node:
#			- At least 1 action connection
#		- Domain Nodes:
#			- At least 1 action connection
#		- Method Nodes:
#			- At least 1 action connection
#		- Applicator Nodes:
#			- At least 1 action connection
#		- Module Nodes:
#			- At least 1 action connection
#	- Output:
#		- Root Node and Compound Node:
#			- There can only be one Always-True-Method connected.
#			- Must have output connections (at least 1)
#			- Connected method pritories have to be unique
#		- Primitive Node:
#			- Can only have at most one output connection
#		- Domain Nodes:
#			- Can only have at most one output connection
#		- Method Nodes:
#			- Requires 1 output connection
#		- Applicator:
#			- Requires 1 output connection
#		- Module Nodes:
#			- Can only have at most one output connection
func _validate_node_connections(domain_graph: HTNDomainGraph) -> bool:
	for node_key: StringName in domain_graph.nodes:
		var connected_node_connection_names: Array[StringName] =\
			HTNConnectionHandler.get_connected_nodes_from_output(domain_graph, node_key)
		var node = domain_graph.nodes[node_key]
		var node_name: String = node.get_node_name()
		if node_name.is_empty() or node_name == "": node_name = node_key

		# We ignore comments here lmao
		if node is HTNCommentNode: continue

		if node is HTNRootNode or node is HTNSplitterNode:
			if not _validate_root_and_compound_nodes(
				domain_graph,
				node_key, node_name,
				connected_node_connection_names
			): return false
		elif node is HTNQuitNode:
			# Check for any amount of task input connections
			if not HTNConnectionHandler.has_connections_from_input(domain_graph, node_key):
				_send_error(domain_graph, node_name, node_key, EMPTY_CONNECTIONS)
				return false
		elif node is HTNTaskNode:
			# Check for at most 1 output connection
			if HTNConnectionHandler.get_connected_nodes_from_output(domain_graph, node_key).size() > 1:
				_send_error(domain_graph, node_name, node_key, OVER_ONE_CONNECTION)
				return false
			# Check for any amount of task input connections
			if not HTNConnectionHandler.has_connections_from_input(domain_graph, node_key):
				_send_error(domain_graph, node_name, node_key, NO_TASK_CONNECTIONS)
				return false
		elif node is HTNDomainNode:
			# Check for at most 1 output connection
			if HTNConnectionHandler.get_connected_nodes_from_output(domain_graph, node_key).size() > 1:
				_send_error(domain_graph, node_name, node_key, OVER_ONE_CONNECTION)
				return false
			# Check for any amount of task input connections
			if not HTNConnectionHandler.has_connections_from_input(domain_graph, node_key):
				_send_error(domain_graph, node_name, node_key, NO_TASK_CONNECTIONS)
				return false
		elif node is HTNMethodNode: # Should cover Always True
			# Check for ONLY one task output connection
			if HTNConnectionHandler.get_connected_nodes_from_output(domain_graph, node_key).size() != 1:
				_send_error(domain_graph, node_name, node_key, ONE_TASK_CONNECTION_REQURIED)
				return false
			# Check for any amount of task input connections
			if not HTNConnectionHandler.has_connections_from_input(domain_graph, node_key):
				_send_error(domain_graph, node_name, node_key, NO_TASK_CONNECTIONS)
				return false
		elif node is HTNApplicatorNode:
			# Check for any amount of task input connections
			if not HTNConnectionHandler.has_connections_from_input(domain_graph, node_key):
				_send_error(domain_graph, node_name, node_key, NO_TASK_CONNECTIONS)
				return false
			# Check for ONLY one task output connection
			if HTNConnectionHandler.get_connected_nodes_from_output(domain_graph, node_key).size() > 1:
				_send_error(domain_graph, node_name, node_key, ONE_TASK_CONNECTION_REQURIED)
				return false
		elif node is HTNModuleBaseNode:
			# Check for any amount of task input connections
			if not HTNConnectionHandler.has_connections_from_input(domain_graph, node_key):
				_send_error(domain_graph, node_name, node_key, NO_TASK_CONNECTIONS)
				return false
			# Check for at most 1 output connection
			if HTNConnectionHandler.get_connected_nodes_from_output(domain_graph, node_key).size() > 1:
				_send_error(domain_graph, node_name, node_key, OVER_ONE_CONNECTION)
				return false
	return true

func _validate_root_and_compound_nodes(domain_graph: HTNDomainGraph, node_key: StringName, node_name: String,
		connected_node_connection_names: Array[StringName]) -> bool:
	# Check for any amount of method output connections
	if not HTNConnectionHandler.has_connections_from_output(domain_graph, node_key):
		_send_error(domain_graph, node_name, node_key, NO_METHOD_CONNECTIONS)
		return false

	# Check for >=1 task connection
	if domain_graph.nodes[node_key] is HTNSplitterNode:
		if not HTNConnectionHandler.has_connections_from_input(domain_graph, node_key):
			_send_error(domain_graph, node_name, node_key, NO_TASK_CONNECTIONS)
			return false

	var found_always_true := false
	var priority_values := {}
	# Evaluate connected methods
	for connection_key: StringName in connected_node_connection_names:
		var node = domain_graph.nodes[connection_key]

		# Look for more than one always true method connection
		if node is HTNMethodNodeAlwaysTrue:
			if not found_always_true:
				found_always_true = true
			else:
				_send_error(domain_graph, node_name, node_key, OVER_ONE_ALWAYS_TRUE_METHOD_CONNECTION)
				return false

		var priority := (node as HTNMethodNode).get_priority()
		var connected_node_name: String = node.get_node_name()
		if connected_node_name == "": connected_node_name = connection_key

		# Check for duplicate priority value
		if priority in priority_values.values():
			var format_string := "%s has the same priority of these nodes [ "
			var error_message := format_string % connected_node_name

			for key: StringName in priority_values.keys():
				if priority_values[key] == priority:
					error_message += key

			_send_error(domain_graph, connected_node_name, connection_key, error_message + " ]")
			return false
		else:
			priority_values[connected_node_name] = priority

	return true

func _send_error(domain_graph: HTNDomainGraph, node_name: String, node_key: StringName, preset_message: String) -> void:
	_focus_error_node(domain_graph, node_key)
	HTNGlobals.notification_handler.send_error("'"+node_name+"' is invalid::"+preset_message)

func _focus_error_node(domain_graph: HTNDomainGraph, node_key: StringName) -> void:
	_highlight_error_node(domain_graph, node_key)
	goto_panel.center_on_node(node_key)

func _highlight_error_node(domain_graph: HTNDomainGraph, node_key: StringName) -> void:
	domain_graph.nodes[node_key].highlight()
	_error_node_key = node_key
