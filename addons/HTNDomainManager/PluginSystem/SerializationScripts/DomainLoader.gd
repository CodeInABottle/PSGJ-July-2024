@tool
class_name HTNDomainLoader
extends Control

const GRAPH_SAVE_PATH := "res://addons/HTNDomainManager/Data/GraphSaves/"
const PRELOADED_GRAPH_TAB = preload("res://addons/HTNDomainManager/PluginSystem/GraphTabManager/PreloadedGraphTab/preloaded_graph_tab.tscn")

@onready var graph_tools_toggle: CheckButton = %GraphToolsToggle
@onready var tab_container: HTNTabGraphManager = %TabContainer
@onready var node_spawn_menu: HTNNodeSpawnMenu = %NodeSpawnMenu

func load_domain(domain_name: String) -> bool:
	var graph_save_file: HTNGraphSave = ResourceLoader.load(GRAPH_SAVE_PATH + domain_name + ".tres")
	if graph_save_file == null:
		return false

	var new_graph: HTNPreloadedGraphTab = PRELOADED_GRAPH_TAB.instantiate()
	tab_container.add_child(new_graph)
	tab_container.move_child(new_graph, 0)
	tab_container.set_tab_button_icon(0, tab_container.CLOSE)
	while tab_container.current_tab > 0:
		tab_container.select_previous_available()

	var domain_graph: HTNDomainGraph = new_graph.load_data(domain_name)
	HTNGlobals.current_graph = domain_graph
	domain_graph.initialize(node_spawn_menu, new_graph, graph_tools_toggle.button_pressed)

	# Create nodes and load data
	for node_key: StringName in graph_save_file["node_positions"]:
		var node_type: String = graph_save_file["node_types"][node_key]
		var node_position: Vector2 = graph_save_file["node_positions"][node_key]

		var node_data = graph_save_file["node_data"][node_key]
		var node: PackedScene = HTNGlobals.get_packed_node_as_flat(node_type)
		new_graph.domain_graph.load_node(node, node_key, node_position, node_data)

	# Connect nodes
	for connection: Dictionary in graph_save_file["connections"]:
		#{from_node: StringName, from_port: int, to_node: StringName, to_port: int}
		HTNConnectionHandler.load_connection(
			domain_graph,
			connection["from_node"],
			connection["from_port"],
			connection["to_node"],
			connection["to_port"]
		)

	domain_graph.is_saved = true
	return true
