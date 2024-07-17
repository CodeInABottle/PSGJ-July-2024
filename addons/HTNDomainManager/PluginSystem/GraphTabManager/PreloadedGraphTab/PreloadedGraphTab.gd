@tool
class_name HTNPreloadedGraphTab
extends HTNGraphTab

func load_data(domain_name: String) -> HTNDomainGraph:
	HTNGlobals.graph_tool_bar_toggled.connect(
		func(state: bool) -> void:
			domain_graph.show_menu = state
	)
	domain_graph = DOMAIN_GRAPH.instantiate()
	add_child(domain_graph)
	is_empty = false
	name = domain_name
	return domain_graph

func get_domain_name() -> String:
	return name.replace("*", "")
