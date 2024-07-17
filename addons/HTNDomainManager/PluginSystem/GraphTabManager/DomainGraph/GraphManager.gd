@tool
class_name HTNDomainGraph
extends GraphEdit

var _node_spawn_menu: HTNNodeSpawnMenu
var _graph_tab: HTNGraphTab
var _current_ID: int = 0
var root_key: String
var domain_name: String = ""
var is_saved := false:
	get: return is_saved
	set(value):
		is_saved = value
		if _graph_tab:
			_graph_tab.tab_save_state(value)
		if value == false:
			HTNGlobals.graph_altered.emit()

var nodes: Dictionary = {}

func initialize(node_spawn_menu: HTNNodeSpawnMenu, graph_tab: HTNGraphTab, graph_tools_button_state: bool) -> void:
	_node_spawn_menu = node_spawn_menu
	_graph_tab = graph_tab
	domain_name = graph_tab.get_domain_name()
	HTNGlobals.current_graph = self

	HTNGlobals.graph_altered.connect(
		func() -> void:
			if HTNGlobals.current_graph != self: return
			if HTNGlobals.validator._error_node_key.is_empty(): return

			nodes[HTNGlobals.validator._error_node_key].dehighlight()
			HTNGlobals.validator._error_node_key = ""
	)

	disconnection_request.connect(_on_disconnection_request)

	add_valid_connection_type(1, 1)
	add_valid_connection_type(2, 2)
	add_valid_connection_type(1, 3)
	add_valid_connection_type(2, 3)

	root_key = _node_spawn_menu.spawn_root()
	show_menu = graph_tools_button_state

func generate_node_key() -> StringName:
	var ID := _current_ID
	_current_ID += 1
	assert(
		_current_ID < 9223372036854775807,
		"YOU ABSOLUTE SANDWICH! HOW?! WHY?! ~Some angry chef most likely"
	)

	var key: String = "Sandwich_" + str(ID)

	while key in nodes:
		key = "Sandwich_" + str(_current_ID)

		_current_ID += 1
		assert(
			_current_ID < 9223372036854775807,
			"YOU ABSOLUTE SANDWICH! HOW?! WHY?! ~Some angry chef most likely"
		)

	return key	# This is the internal ID and you will love it >:3 ~ I was eating lol

func register_node(node: GraphNode, reg_key: StringName="") -> String:
	var node_key: StringName
	if reg_key != "":
		node_key = reg_key
	else:
		node_key = generate_node_key()

	nodes[node_key] = node
	node.name = node_key
	is_saved = false
	return node_key

func clear() -> void:
	var node_keys: Array = nodes.keys()
	for node_key in node_keys:
		var node = nodes[node_key]
		if node is HTNRootNode: continue
		_delete_node(node)
	_current_ID = 1
	HTNGlobals.graph_altered.emit()

func get_node_offset_by_key(node_key: StringName) -> Dictionary:
	if node_key not in nodes: return {}

	var node = nodes[node_key]
	return {
		"offset": node.position_offset,
		"size": node.size
	}

func get_node_keys_with_meta() -> Dictionary:
	var data := {}
	for node_key: StringName in nodes.keys():
		var type = get_node_type(node_key)
		assert(type != "Unknown", "This shouldn't be unknown. This is a bug.")

		data[node_key] = {
			"name": (nodes[node_key] as HTNBaseNode).get_node_name(),
			"type": type
		}
	return data

func get_task_key_name_pair() -> Dictionary:
	var names: Dictionary = {}
	for node_key: StringName in nodes:
		if nodes[node_key] is HTNTaskNode:
			names[node_key] = (nodes[node_key] as HTNTaskNode).get_node_name()
	return names

func get_domain_key_name_pair() -> Dictionary:
	var names: Dictionary = {}
	for node_key: StringName in nodes:
		if nodes[node_key] is HTNDomainNode:
			names[node_key] = (nodes[node_key] as HTNDomainNode).get_node_name()
	return names

func get_quits() -> Array[StringName]:
	var keys: Array[StringName] = []
	for node_key: StringName in nodes:
		if nodes[node_key] is HTNQuitNode:
			keys.push_back(node_key)
	return keys

func get_node_type(node_key: StringName) -> String:
	return nodes[node_key].get_node_type()

func get_node_data(node_key: StringName) -> Dictionary:
	return nodes[node_key].get_data()

func get_every_node_til_compound(node_key: String) -> Array[StringName]:
	var task_chain: Array[StringName] = []
	_get_every_node_til_compound_helper(node_key, task_chain)

	return task_chain

func load_node(node: PackedScene, node_key: StringName,
		node_position: Vector2, node_data: Dictionary) -> void:
	if not HTNGlobals.is_node_ready(): return
	if node == HTNGlobals.get_root():
		nodes[root_key].position_offset = node_position
	else:
		var node_instance: GraphNode = node.instantiate()
		add_child(node_instance)
		register_node(node_instance, node_key)
		node_instance.initialize()
		node_instance.load_data(node_data)
		node_instance.position_offset = node_position

func _get_every_node_til_compound_helper(current_key: String, task_chain: Array[StringName]) -> void:
	var connected_nodes: Array[StringName]\
		= HTNConnectionHandler.get_connected_nodes_from_output(self, current_key)
	# We're done -- Stopped at dead end
	if connected_nodes.size() == 0:
		return
	assert(connected_nodes.size() == 1, "This should always be 1. This is a bug.")

	var connected_node := connected_nodes[0]
	# We're done -- Stopped at Splitter
	if nodes[connected_node] is HTNSplitterNode:
		task_chain.push_back(connected_node)
		return

	# We're done -- Stopped before recurion
	if connected_node in task_chain: return

	# We just keep on going
	task_chain.push_back(connected_node)
	_get_every_node_til_compound_helper(connected_node, task_chain)

func _delete_node(node: HTNBaseNode) -> void:
	HTNConnectionHandler.remove_connections(self, node)
	if not nodes.erase(node.name):
		push_error(node.name + " did not exist and is trying to erase.")
	node.queue_free()

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	HTNConnectionHandler.load_connection(self, from_node, from_port, to_node, to_port)

func _on_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	_node_spawn_menu.connect_node_data = {
		"from_node": from_node,
		"from_port": from_port,
		"release_position": release_position
	}
	_node_spawn_menu.enable(HTNConnectionHandler.get_output_port_type(self, from_node, from_port))

func _on_delete_nodes_request(selected_nodes: Array[StringName]) -> void:
	while not selected_nodes.is_empty():
		var node_name: String = selected_nodes.pop_back()
		# Can't remove the root node
		var node = nodes[node_name]
		if node is HTNRootNode:
			continue

		_delete_node(node)
	is_saved = false

func _on_copy_nodes_request() -> void:
	pass # Replace with function body.

func _on_paste_nodes_request() -> void:
	pass # Replace with function body.

func _on_popup_request(_position: Vector2) -> void:
	_node_spawn_menu.enable()

func _on_end_node_move() -> void:
	is_saved = false

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	is_saved = false
