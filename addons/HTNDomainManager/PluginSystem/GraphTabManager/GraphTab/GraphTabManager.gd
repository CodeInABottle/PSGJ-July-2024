@tool
class_name HTNGraphTab
extends Control

const DOMAIN_GRAPH = preload("res://addons/HTNDomainManager/PluginSystem/GraphTabManager/DomainGraph/domain_graph.tscn")

signal tab_created(graph: HTNDomainGraph)

var domain_graph: HTNDomainGraph = null
var is_empty := true

func get_domain_name() -> String:
	if %DomainLineEdit != null:
		return %DomainLineEdit.text.to_pascal_case()
	else:
		return name.replace("*", "")

func tab_save_state(state: bool) -> void:
	if state:
		name = name.replace("*", "")
	elif not state and not name.ends_with("*"):
		name += "*"

func _on_create_button_pressed() -> void:
	var graph_tab_container: HTNTabGraphManager = get_parent_control()
	if graph_tab_container == null: return

	# No name given
	if get_domain_name().is_empty(): return

	# Check if tab was already created
	if not graph_tab_container.validate_tab_creation(get_domain_name()):
		return

	name = get_domain_name() + "*"
	domain_graph = DOMAIN_GRAPH.instantiate()
	add_child(domain_graph)
	HTNGlobals.graph_tool_bar_toggled.connect(
		func(state: bool) -> void:
			domain_graph.show_menu = state
	)
	tab_created.emit(domain_graph)
	is_empty = false

	%EmptyFieldsContainer.queue_free()
