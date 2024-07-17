@tool
class_name HTNNodeSpawnMenu
extends Control

## Node Data
#Color Code:
#- Compound/Root <-> Methods: 4f8fba - Blue
#- Tasks <-> Tasks: 468232 - Green
#
#IDs:
#- Compound/Root <-> Methods: 1
#- Tasks <-> Tasks: 2

const TREE_DROP_BUTTON = preload("res://addons/HTNDomainManager/PluginSystem/Components/Tree/TreeDropButton/tree_drop_button.tscn")

@onready var search_bar: LineEdit = %SearchBar
@onready var node_buttons: VBoxContainer = %NodeButtons

var _mouse_local_position: Vector2
var can_be_opened := false
var connect_node_data: Dictionary = {}

func _ready() -> void:
	if not Engine.is_editor_hint():
		set_process_unhandled_input(false)
		return

	_add_nodes_to_menu()
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
			if visible:
				connect_node_data = {}
				hide()
	elif event is InputEventKey and event.is_pressed():
		if (event as InputEventKey).keycode == KEY_ESCAPE:
			if visible:
				connect_node_data = {}
				hide()

func enable(port_type: int=-1) -> void:
	if visible and port_type == -1:
		hide()
		return

	match port_type:
		-1, 0:
			_show_all()
		1:
			for tree_drop: TreeDropButton in node_buttons.get_children():
				tree_drop.filter(HTNGlobals.ON_PORT_BLUE)
		2:
			for tree_drop: TreeDropButton in node_buttons.get_children():
				tree_drop.filter(HTNGlobals.ON_PORT_GREEN)
		_:
			_hide_all()
	show()
	global_position = get_global_mouse_position()

func spawn_root() -> String:
	assert(HTNGlobals.current_graph != null, "Current Graph is NULL")

	var root_instance: HTNRootNode = HTNGlobals.get_root().instantiate()
	HTNGlobals.current_graph.add_child(root_instance)
	root_instance.initialize()
	var root_key: String = HTNGlobals.current_graph.register_node(root_instance)
	_set_node_position(
		root_instance,
		Vector2.ZERO,
		root_instance.size * Vector2(0.5, 1.0)
	)
	return root_key

func _add_nodes_to_menu() -> void:
	for child: Control in node_buttons.get_children():
		if child.is_queued_for_deletion(): continue
		child.queue_free()

	var categories: Array = HTNGlobals.get_categories()
	categories.sort()
	for category: String in categories:
		if category == "Root": continue

		var tree_drop_button_instance: TreeDropButton = TREE_DROP_BUTTON.instantiate()
		node_buttons.add_child(tree_drop_button_instance)
		tree_drop_button_instance.set_title(category)

		var node_names: Array = HTNGlobals.get_sub_nodes_from_categories(category)
		node_names.sort()
		for node_name: String in node_names:
			tree_drop_button_instance.add_menu_item(
				node_name,
				func() -> void:
					_add_node(HTNGlobals.get_packed_node_as_flat(node_name))
			)

func _show_all() -> void:
	for tree_drop_down: TreeDropButton in node_buttons.get_children():
		tree_drop_down.show_all()
	search_bar.editable = true

func _hide_all() -> void:
	for tree_drop_down: TreeDropButton in node_buttons.get_children():
		tree_drop_down.hide()
	search_bar.editable = false

func _add_node(node: PackedScene) -> HTNBaseNode:
	hide()
	var node_instance: HTNBaseNode = node.instantiate()
	HTNGlobals.current_graph.add_child(node_instance)
	HTNGlobals.current_graph.register_node(node_instance)

	if connect_node_data.is_empty():
		var node_size := (node_instance as HTNBaseNode).size
		_set_node_position(
			node_instance,
			_mouse_local_position,
			-(node_size / 2.0)
		)
	else:
		_place_and_connect(node_instance)

	node_instance.initialize()
	return node_instance

func _place_and_connect(node_instance: HTNBaseNode) -> void:
	_set_node_position(
		node_instance,
		connect_node_data["release_position"],
		-(node_instance.size / 2.0)
	)

	var from_node: StringName = connect_node_data["from_node"]
	var from_port: int = connect_node_data["from_port"]
	for idx in node_instance.get_input_port_count():
		var to_node := node_instance.name
		var to_port := node_instance.get_input_port_slot(idx)

		if HTNConnectionHandler.is_connection_valid(
				HTNGlobals.current_graph, from_node, from_port, to_node, to_port):
			HTNGlobals.current_graph.connect_node(from_node, from_port, to_node, to_port)
			connect_node_data.clear()
			return
	connect_node_data.clear()

func _set_node_position(node: HTNBaseNode, target_position: Vector2, offset: Vector2) -> void:
	var scroll_offset: Vector2 = HTNGlobals.current_graph.scroll_offset
	var zoom: float = HTNGlobals.current_graph.zoom
	node.set_position_offset((target_position + scroll_offset) / zoom + offset)

func _on_visibility_changed() -> void:
	if HTNGlobals.current_graph == null:
		hide()
		return

	if visible:
		_mouse_local_position = HTNGlobals.current_graph.get_local_mouse_position()

func _on_search_bar_text_changed(new_text: String) -> void:
	#for tree_drop: TreeDropButton in node_buttons.get_children():
		#tree_drop.filter(ON_PORT_BLUE)
	pass
