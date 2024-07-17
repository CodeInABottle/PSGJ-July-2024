@tool
class_name HTNConditionEditor
extends Panel

const CONDITION_LINE = preload("res://addons/HTNDomainManager/PluginSystem/ConditionEditor/ConditionLine/condition_line.tscn")

@onready var condition_line_container: VBoxContainer = %ConditionLineContainer
@onready var nickname_line_edit: LineEdit = %NicknameLineEdit
@onready var search_bar: LineEdit = %SearchBar

var _method_node: HTNMethodNode

func _ready() -> void:
	hide()

func open(node: HTNMethodNode, data: Dictionary) -> void:
	show()
	_method_node = node
	nickname_line_edit.text = _method_node._nick_name
	search_bar.clear()
	_filter_children("")
	if data.is_empty(): return

	for key: String in data.keys():
		_create_and_load_condition({
			"CompareID": data[key]["CompareID"],
			"RangeID": data[key]["RangeID"],
			"SingleID": data[key]["SingleID"],
			"WorldState": key,
			"Value":  data[key]["Value"],
			"RangeInclusivity":  data[key]["RangeInclusivity"]
		})

func _filter_children(filter: String) -> void:
	var filter_santized := filter.to_lower()
	for child: HTNConditionLine in condition_line_container.get_children():
		var line_name: String = child.world_state_line_editor.text.to_lower()
		if filter_santized.is_empty() or line_name.contains(filter_santized):
			child.show()
		else:
			child.hide()

func _create_and_load_condition(data: Dictionary={}) -> void:
	var condition_line := CONDITION_LINE.instantiate()
	condition_line_container.add_child(condition_line)
	condition_line.initialize(data)

func _get_data() -> Dictionary:
	var data := {}

	for child: HTNConditionLine in condition_line_container.get_children():
		var child_data: Dictionary = child.get_data()
		if child_data["WorldState"] in data: continue	# Skip Repeats

		data[child_data["WorldState"]] = {
			"CompareID": child_data["CompareID"],
			"RangeID": child_data["RangeID"],
			"SingleID": child_data["SingleID"],
			"Value":  child_data["Value"],
			"RangeInclusivity":  child_data["RangeInclusivity"]
		}

	return data

func _on_add_button_pressed() -> void:
	_create_and_load_condition()

func _on_close_button_pressed() -> void:
	hide()
	# Save Data
	_method_node._nick_name = nickname_line_edit.text
	var data := _get_data()
	var different_data := false
	for key: String in data:
		if key not in _method_node.condition_data.keys():
			different_data = true
			break
		if data[key] != _method_node.condition_data[key]:
			different_data = true
			break
	_method_node.condition_data = data

	# Reset Editor
	for child: HTNConditionLine in condition_line_container.get_children():
		child.queue_free()

	if different_data:
		HTNGlobals.current_graph.is_saved = false

func _on_search_bar_text_changed(new_text: String) -> void:
	_filter_children(new_text)
