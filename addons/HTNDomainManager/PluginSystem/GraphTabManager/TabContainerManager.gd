@tool
class_name HTNTabGraphManager
extends TabContainer

const GRAPH_TAB = preload("res://addons/HTNDomainManager/PluginSystem/GraphTabManager/GraphTab/graph_tab.tscn")
const CLOSE = preload("res://addons/HTNDomainManager/PluginSystem/Icons/Close.svg")

@export var node_spawn_menu: HTNNodeSpawnMenu
@export var graph_tools_toggle: CheckButton

var _regex: RegEx

func initialize() -> void:
	_regex = RegEx.new()
	_regex.compile("[^A-Za-z0-9]")
	_create_new_tab()

func validate_tab_creation(domain_name: String) -> bool:
	if domain_name[0].is_valid_int():
		HTNGlobals.notification_handler.send_error("Domain name can't start with a number.")
		return false
	var result = _regex.search(domain_name)
	if result:
		HTNGlobals.notification_handler.send_error("Alphanumeric characters only! Found: ["+result.get_string(0)+"]")
		return false

	if HTNFileManager.check_if_domain_name_exists(domain_name):
		HTNGlobals.notification_handler.send_error("Domain already exists.")
		return false

	for child: Control in get_children():
		if child.name == domain_name:
			HTNGlobals.notification_handler.send_error("There extists a tab with that domain name.")
			return false

	return true

func delete_tab_if_open(domain_name: String) -> void:
	for i in get_tab_count():
		var tab_ctx: HTNGraphTab = get_tab_control(i)
		var tab_name: String = tab_ctx.name.replace("*", "")
		if tab_name == domain_name:
			tab_ctx.queue_free()
			return

func switch_to_tab(domain_name: String) -> bool:
	for i in get_tab_count():
		var tab_ctx: HTNGraphTab = get_tab_control(i)
		var tab_name: String = tab_ctx.name.replace("*", "")
		if tab_name == domain_name:
			if i > current_tab:
				while i > current_tab:
					select_next_available()
			elif i < current_tab:
				while i < current_tab:
					select_previous_available()
			return true
	return false

func _create_new_tab() -> void:
	var tab_instance := GRAPH_TAB.instantiate()
	tab_instance.tab_created.connect(
		func(graph: HTNDomainGraph) -> void: _on_tab_created(graph, tab_instance)
	)
	add_child(tab_instance)

func _on_tab_created(graph: HTNDomainGraph, tab_instance: HTNGraphTab) -> void:
	graph.initialize(node_spawn_menu, tab_instance, graph_tools_toggle.button_pressed)
	HTNGlobals.graph_altered.emit()
	set_tab_button_icon(current_tab, CLOSE)
	_create_new_tab()

func _on_tab_changed(tab: int) -> void:
	if get_tab_count() == 0: return

	var tab_ctx: HTNGraphTab = get_tab_control(tab)
	HTNGlobals.current_graph = tab_ctx.domain_graph
	HTNGlobals.graph_tab_changed.emit()

func _on_tab_button_pressed(tab: int) -> void:
	if get_tab_count() == 0: return
	var tab_control: HTNGraphTab = get_tab_control(tab)

	if tab_control.domain_graph and tab_control.domain_graph.is_saved:
		tab_control.queue_free()
	else:
		HTNGlobals.warning_box.open(
			"""You are about to delete an unsaved tab.
			Continue?""",
			func() -> void:
				tab_control.queue_free(),
			Callable()
		)
	HTNGlobals.graph_altered.emit()
