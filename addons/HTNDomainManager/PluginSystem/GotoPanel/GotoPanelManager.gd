@tool
class_name HTNGoToManager
extends VBoxContainer

@onready var goto_root_button: Button = %GotoRootButton
@onready var search_bar: LineEdit = %SearchBar
@onready var goto_container: VBoxContainer = %GotoContainer

func initialize() -> void:
	HTNGlobals.graph_altered.connect(_refresh)
	HTNGlobals.graph_tab_changed.connect(_refresh)
	HTNGlobals.node_name_altered.connect(_refresh)
	hide()

func _refresh() -> void:
	if not visible or not search_bar: return

	search_bar.clear()
	goto_root_button.disabled = (HTNGlobals.current_graph == null)

	# Clear container
	for child: Button in goto_container.get_children():
		if child.is_queued_for_deletion(): continue
		child.queue_free()

	if not HTNGlobals.current_graph:
		search_bar.editable = false
		return

	var node_naming_data: Dictionary = HTNGlobals.current_graph.get_node_keys_with_meta()
	var node_keys: Array[StringName] = []
	for node_key: StringName in node_naming_data.keys():
		if node_key == HTNGlobals.current_graph.root_key: continue
		node_keys.push_back(node_key)

	if node_keys.is_empty():
		search_bar.editable = false
		return

	# Sort based on type, then sandwich ID
	node_keys.sort_custom(
		func(node_key_A: StringName, node_key_B: StringName) -> bool:
			if node_naming_data[node_key_A]["type"] < node_naming_data[node_key_B]["type"]:
				return true
			else:
				return int(node_key_A.replace("Sandwich_", "")) < int(node_key_B.replace("Sandwich_", ""))
	)

	for node_key: StringName in node_keys:
		var node_name: String = node_naming_data[node_key]["name"]
		var node_type: String = node_naming_data[node_key]["type"]
		if node_name.is_empty():
			node_name = node_type + " - " + node_key
		else:
			node_name = node_type + " - " + node_name

		var button_instance := Button.new()
		button_instance.text = node_name
		button_instance.pressed.connect( func() -> void: center_on_node(node_key) )
		goto_container.add_child(button_instance)

	search_bar.editable = true

func center_on_node(node_key: StringName) -> void:
	var data: Dictionary = HTNGlobals.current_graph.get_node_offset_by_key(node_key)
	if data.is_empty(): return

	HTNGlobals.current_graph.zoom = 1.0
	var center: Vector2 = HTNGlobals.current_graph.size / 2.0
	var offset: Vector2 = data["offset"] + data["size"] * Vector2(0.5, 1.0) - center
	HTNGlobals.current_graph.scroll_offset = offset / HTNGlobals.current_graph.zoom

func _on_visibility_changed() -> void:
	if search_bar:
		search_bar.clear()
	if visible:
		_refresh()

func _on_goto_root_button_pressed() -> void:
	center_on_node(HTNGlobals.current_graph.root_key)

func _on_search_bar_text_changed(new_text: String) -> void:
	var filter_santized := new_text.to_lower()
	for child: Button in goto_container.get_children():
		var line_name: String = child.text.to_lower()
		if filter_santized.is_empty() or line_name.contains(filter_santized):
			child.show()
		else:
			child.hide()
