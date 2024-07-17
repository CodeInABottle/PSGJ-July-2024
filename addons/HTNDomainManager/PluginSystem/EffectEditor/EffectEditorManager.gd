@tool
class_name HTNEffectEditor
extends Panel

const EFFECT_LINE = preload("res://addons/HTNDomainManager/PluginSystem/EffectEditor/EffectLine/effect_line.tscn")

@onready var nickname_line_edit: LineEdit = %NicknameLineEdit
@onready var searchbar: LineEdit = %Searchbar
@onready var line_container: VBoxContainer = %LineContainer

var _applicator_node: HTNApplicatorNode

func _ready() -> void:
	hide()

func open(applicator_node: HTNApplicatorNode, data: Dictionary) -> void:
	_applicator_node = applicator_node
	nickname_line_edit.text = _applicator_node._nick_name
	searchbar.clear()
	_filter_children("")
	if not data.is_empty():	# Load Data
		for key: StringName in data.keys():
			_create_and_load({
				"WorldState": key,
				"TypeID": data[key]["TypeID"],
				"Value": data[key]["Value"]
			})
	show()

func _get_data() -> Dictionary:
	var data := {}
	for child: HTNEffectLine in line_container.get_children():
		var child_data: Dictionary = child.get_data()
		if child_data["WorldState"] in data: continue	# Skip Repeats
		data[child_data["WorldState"]] = {
			"TypeID": child_data["TypeID"],
			"Value": child_data["Value"]
		}

	return data

func _create_and_load(data: Dictionary) -> void:
	var effect_line_instance := EFFECT_LINE.instantiate()
	line_container.add_child(effect_line_instance)
	effect_line_instance.initialize(data)

func _filter_children(filter: String) -> void:
	if line_container.get_child_count() == 0: return

	var filter_santized := filter.to_lower()
	for child: HTNEffectLine in line_container.get_children():
		var line_name: String = child.world_state_line_edit.text.to_lower()
		if filter_santized.is_empty() or line_name.contains(filter_santized):
			child.show()
		else:
			child.hide()

func _on_add_button_pressed() -> void:
	_create_and_load({})

func _on_searchbar_text_changed(new_text: String) -> void:
	_filter_children(new_text)

func _on_close_button_pressed() -> void:
	hide()
	_applicator_node._nick_name = nickname_line_edit.text
	_applicator_node.effect_data = _get_data()

	for child: HTNEffectLine in line_container.get_children():
		child.queue_free()
	HTNGlobals.graph_altered.emit()
